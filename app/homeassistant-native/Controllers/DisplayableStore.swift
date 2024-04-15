import ApplicationConfiguration
import Factory
import Foundation
import RealmSwift
import Spyable

@Spyable
protocol DisplayableStoring {
    func root() -> DisplayableModelObject?

    func stackConfiguration(displayableModelObjectID: String) -> StackConfiguration
    func buttonConfiguration(displayableModelObjectID: String) -> ButtonConfiguration
    func stateDisplayConfiguration(displayableModelObjectID: String) -> StateDisplayConfiguration

    func write(_ block: () -> Void) async

    func delete(_ objects: [DisplayableModelObject]) async

    func observe(
        _ object: Object?,
        onChange: @escaping () async -> Void,
        onDelete: EmptyCallback?
    ) -> NotificationToken?
}

struct DisplayableStore: DisplayableStoring {
    @Injected(\.databaseManager) private var databaseManager

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
    func root() -> DisplayableModelObject? {
        return databaseManager.database().objects(DisplayableModelObject.self).filter({
            $0.parentSection == nil
        }).first
    }

    @MainActor
    func stackConfiguration(displayableModelObjectID: String) -> StackConfiguration {
        let displayable = databaseManager.database().object(
            ofType: DisplayableModelObject.self,
            forPrimaryKey: displayableModelObjectID
        )!
        return databaseManager.database().object(
            ofType: StackConfiguration.self,
            forPrimaryKey: displayable.configurationID
        )!
    }

    @MainActor
    func buttonConfiguration(displayableModelObjectID: String) -> ButtonConfiguration {
        let displayable = databaseManager.database().object(
            ofType: DisplayableModelObject.self,
            forPrimaryKey: displayableModelObjectID
        )!
        return databaseManager.database().object(
            ofType: ButtonConfiguration.self,
            forPrimaryKey: displayable.configurationID
        )!
    }

    @MainActor
    func stateDisplayConfiguration(displayableModelObjectID: String) -> StateDisplayConfiguration {
        let displayable = databaseManager.database().object(
            ofType: DisplayableModelObject.self,
            forPrimaryKey: displayableModelObjectID
        )!
        return databaseManager.database().object(
            ofType: StateDisplayConfiguration.self,
            forPrimaryKey: displayable.configurationID
        )!
    }

    @MainActor
    func write(_ block: () -> Void) async {
        try? await databaseManager.database().asyncWrite {
            block()
        }
    }

    @MainActor
    func delete(_ objects: [DisplayableModelObject]) async {
        let db = databaseManager.database()
        for object in objects {
            switch object.type {
                case .stack:
                    let configuration = stackConfiguration(displayableModelObjectID: object.id)
                    await delete(Array(configuration.children))
                    await write {
                        db.delete(configuration)
                    }
                case .button:
                    let configuration = buttonConfiguration(displayableModelObjectID: object.id)
                    await write {
                        db.delete(configuration)
                    }
                case .stateDisplay:
                    let configuration = stateDisplayConfiguration(displayableModelObjectID: object.id)
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
}
