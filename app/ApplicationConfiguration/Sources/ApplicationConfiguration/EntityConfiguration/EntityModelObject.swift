import Foundation
import RealmSwift

public class EntityModelObject: Object, ObjectKeyIdentifiable {
    @Persisted public var entityID: String = ""
    @Persisted public var enabled: Bool = false
    @Persisted public var sectionID: String?
    @Persisted public var position: Int = 0
    @Persisted public var state: String = ""
    @Persisted public var attributes: EntityAttributeModelObject! = .init()

    public override class func primaryKey() -> String? {
        return "entityID"
    }
}

public class EntityAttributeModelObject: EmbeddedObject {
    @Persisted public var unit: String?
    @Persisted public var name: String?
    @Persisted public var deviceClass: String?
    @Persisted public var stateClass: String?
    @Persisted public var temperature: Double?
    @Persisted public var humidity: Int?
    @Persisted public var windSpeed: Double!
    @Persisted public var icon: String?
    @Persisted public var rgb: List<Double>
    @Persisted public var hs: List<Double>
    @Persisted public var brightness: Double?
    @Persisted public var hueType: String?
}

public class Entity: Projection<EntityModelObject>, Identifiable {
    @Projected(\EntityModelObject.entityID) public var id
    @Projected(\EntityModelObject.enabled) public var enabled
    @Projected(\EntityModelObject.state) public var state
    @Projected(\EntityModelObject.attributes.unit) public var unit
    @Projected(\EntityModelObject.attributes.name) public var name
    @Projected(\EntityModelObject.attributes.deviceClass) public var deviceClass
    @Projected(\EntityModelObject.attributes.stateClass) public var stateClass
    @Projected(\EntityModelObject.attributes.temperature) public var temperature
    @Projected(\EntityModelObject.attributes.humidity) public var humidity
    @Projected(\EntityModelObject.attributes.windSpeed) public var windSpeed
    @Projected(\EntityModelObject.attributes.icon) public var icon
    @Projected(\EntityModelObject.attributes.hueType) public var hueType
    @Projected(\EntityModelObject.attributes.brightness) public var brightness
    @Projected(\EntityModelObject.attributes.hs) public var hs

    public func displayName() -> String {
        if let name = name {
            return name
        }
        return id
    }
}
