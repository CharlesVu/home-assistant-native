import ApplicationConfiguration
import Factory
import Foundation
import HomeAssistant
import RealmSwift
import Spyable

typealias EmptyCallback = () async -> Void

@Spyable
protocol EntityStoring {
    func listenForEntityChange(
        id: String,
        onChange: @escaping (Entity) -> Void,
        onDelete: EmptyCallback?
    ) -> NotificationToken?

    func entity(id: String) async -> Entity?
    func allEntitites() async -> [Entity]
    func updateEntity(newState: EntityState) async
    func updateEntities(newStates: [EntityState]) async
}

extension EntityStoring {
    func listenForEntityChange(
        id: String,
        onChange: @escaping (Entity) -> Void
    ) -> NotificationToken? {
        listenForEntityChange(id: id, onChange: onChange, onDelete: nil)
    }
}

struct EntityStore: EntityStoring {
    @Injected(\.databaseManager) var databaseManager

    public func listenForEntityChange(
        id: String,
        onChange: @escaping (Entity) -> Void,
        onDelete: EmptyCallback?
    ) -> NotificationToken? {
        let entityObject = databaseManager.database()
            .object(ofType: EntityModelObject.self, forPrimaryKey: id)

        if let entityObject {
            onChange(Entity(projecting: entityObject))
        }

        return entityObject?
            .observe({ changes in
                switch changes {
                    case .change(let object, _):
                        if let obj = object as? EntityModelObject {
                            onChange(Entity(projecting: obj))
                        }
                    case .deleted:
                        Task { await onDelete?() }
                    default:
                        ()
                }
            })
    }

    @MainActor
    public func entity(id: String) async -> Entity? {
        guard
            let entityObject = databaseManager.database()
                .object(ofType: EntityModelObject.self, forPrimaryKey: id)
        else {
            return nil
        }
        return Entity(projecting: entityObject)
    }

    @MainActor
    func allEntitites() async -> [Entity] {
        return Array(databaseManager.database().objects(Entity.self))
    }

    @MainActor
    func updateEntity(newState: EntityState) async {
        let db = databaseManager.database()

        try? await db.asyncWrite {
            let model = EntityModelObject()
            model.entityID = newState.entityId
            model.state = newState.state
            model.attributes.update(newState.attributes)
            db.add(model, update: .modified)
        }
    }

    @MainActor
    func updateEntities(newStates: [EntityState]) async {
        let db = databaseManager.database()

        try? await db.asyncWrite {
            newStates.map {
                let model = EntityModelObject()
                model.entityID = $0.entityId
                model.state = $0.state
                model.attributes.update($0.attributes)
                return model
            }.forEach {
                db.add($0, update: .modified)
            }
        }
    }
}

private extension EntityAttributeModelObject {
    func update(_ model: EntityAttribute) {
        self.unit = model.unit
        self.name = model.name
        if let deviceClass = model.deviceClass {
            self.deviceClass = .init(rawValue: deviceClass)
        }
        self.stateClass = model.stateClass
        self.temperature = model.temperature
        self.humidity = model.humidity
        self.windSpeed = model.windSpeed
        self.icon = model.icon
        if let rgb = model.rgb {
            self.rgb = List()
            rgb.forEach { self.rgb.append($0) }
        }
        if let hs = model.hs {
            self.hs = List()
            hs.forEach { self.hs.append($0) }
        }
        self.brightness = model.brightness
        self.hueType = model.hueType
    }
}
