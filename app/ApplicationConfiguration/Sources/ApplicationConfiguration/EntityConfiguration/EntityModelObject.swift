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

    public func displayName() -> String {
        if let name = attributes?.name {
            return name
        }
        return entityID
    }
}

public class EntityAttributeModelObject: Object {
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
