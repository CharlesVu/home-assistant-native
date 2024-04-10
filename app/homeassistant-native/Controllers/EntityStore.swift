import ApplicationConfiguration
import Factory
import Foundation
import HomeAssistant
import RealmSwift

protocol EntityStoring {
    func listenForEntityChange(
        id: String,
        callback: @escaping (Entity) -> Void
    ) -> NotificationToken?

    func entity(id: String) async -> Entity?
    func allEntitites() async -> [Entity]
    func updateEntity(newState: EntityState) async
}

struct EntityStore: EntityStoring {
    @Injected(\.databaseManager) var databaseManager

    public func listenForEntityChange(
        id: String,
        callback: @escaping (Entity) -> Void
    ) -> NotificationToken? {
        let entityObject = databaseManager.database()
            .object(ofType: EntityModelObject.self, forPrimaryKey: id)

        if let entityObject {
            callback(Entity(projecting: entityObject))
        }

        return entityObject?
            .observe({ changes in
                switch changes {
                    case .change(let object, _):
                        if let obj = object as? EntityModelObject {
                            callback(Entity(projecting: obj))
                        }
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
        var model: EntityModelObject
        if let existingModel = db.object(
            ofType: EntityModelObject.self,
            forPrimaryKey: newState.entityId
        ) {
            model = existingModel
        } else {
            model = .init()
            model.entityID = newState.entityId
        }

        try? await db.asyncWrite {
            model.state = newState.state
            model.attributes.update(newState.attributes)
            db.add(model, update: .modified)
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
