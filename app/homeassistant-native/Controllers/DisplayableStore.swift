import ApplicationConfiguration
import Foundation
import RealmSwift
import Spyable

@Spyable
protocol DisplayableStoring {
    func root() async -> DisplayableModelObject?

    func stackConfiguration(displayableModelObjectID: String) async -> StackConfiguration
    func buttonConfiguration(displayableModelObjectID: String) async -> ButtonConfiguration
    func stateDisplayConfiguration(displayableModelObjectID: String) async -> StateDisplayConfiguration

    func write(_ block: () -> Void) async
    func delete(_ objects: [DisplayableModelObject]) async

    func createRootStack() async

    func observe(
        _ object: Object?,
        onChange: @escaping () async -> Void,
        onDelete: EmptyCallback?
    ) -> NotificationToken?
}

class DisplayableStore: DisplayableStoring, ObservableObject {
    private let databaseProvider: any RealmProviding

    init(databaseProvider: any RealmProviding) {
        self.databaseProvider = databaseProvider
    }

    public func observe(
        _ object: Object?,
        onChange: @escaping () async -> Void,
        onDelete: EmptyCallback?
    ) -> NotificationToken? {
        return object?
            .observe({ changes in
                switch changes {
                    case .change(_, _):
                        Task { await onChange() }
                    case .deleted:
                        Task { await onDelete?() }
                    default:
                        ()
                }
            })
    }

    @MainActor
    func root() async -> DisplayableModelObject? {
        return databaseProvider.database().objects(DisplayableModelObject.self).filter({
            $0.parentSection == nil
        }).first
    }

    @MainActor
    func stackConfiguration(displayableModelObjectID: String) async -> StackConfiguration {
        let displayable = databaseProvider.database().object(
            ofType: DisplayableModelObject.self,
            forPrimaryKey: displayableModelObjectID
        )!
        return databaseProvider.database().object(
            ofType: StackConfiguration.self,
            forPrimaryKey: displayable.configurationID
        )!
    }

    @MainActor
    func buttonConfiguration(displayableModelObjectID: String) async -> ButtonConfiguration {
        let displayable = databaseProvider.database().object(
            ofType: DisplayableModelObject.self,
            forPrimaryKey: displayableModelObjectID
        )!
        return databaseProvider.database().object(
            ofType: ButtonConfiguration.self,
            forPrimaryKey: displayable.configurationID
        )!
    }

    @MainActor
    func stateDisplayConfiguration(displayableModelObjectID: String) async -> StateDisplayConfiguration {
        let displayable = databaseProvider.database().object(
            ofType: DisplayableModelObject.self,
            forPrimaryKey: displayableModelObjectID
        )!
        return databaseProvider.database().object(
            ofType: StateDisplayConfiguration.self,
            forPrimaryKey: displayable.configurationID
        )!
    }

    @MainActor
    func write(_ block: () -> Void) async {
        try? await databaseProvider.database().asyncWrite {
            block()
        }
    }

    @MainActor
    func delete(_ objects: [DisplayableModelObject]) async {
        let db = databaseProvider.database()
        for object in objects {
            switch object.type {
                case .stack:
                    let configuration = await stackConfiguration(displayableModelObjectID: object.id)
                    await delete(Array(configuration.children))
                    await write {
                        db.delete(configuration)
                    }
                case .button:
                    let configuration = await buttonConfiguration(displayableModelObjectID: object.id)
                    await write {
                        db.delete(configuration)
                    }
                case .stateDisplay:
                    let configuration = await stateDisplayConfiguration(displayableModelObjectID: object.id)
                    await write {
                        db.delete(configuration)
                    }
                case .octopus:
                    ()

            }
            await write {
                db.delete(object)
            }
        }
    }

    @MainActor
    func createRootStack() async {
        let db = databaseProvider.database()

        await write {
            let configuration = StackConfiguration()
            db.add(configuration)

            let newStackObject = DisplayableModelObject()
            newStackObject.type = .stack
            newStackObject.configurationID = configuration.id
            db.add(newStackObject)
        }
    }
}
