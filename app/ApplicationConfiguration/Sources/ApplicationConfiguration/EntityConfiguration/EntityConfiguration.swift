import Foundation
import RealmSwift

public class EntityConfiguration: Identifiable, Hashable, Equatable {
    public var entityID: String
    public var enabled: Bool
    public var sectionID: String?
    public var position: String
    public var friendlyName: String?

    init(model: EntityConfigurationModelObject) {
        entityID = model.entityID
        enabled = model.enabled
        sectionID = model.sectionID
        position = String(model.position)
    }

    public init(entityID: String) {
        self.entityID = entityID
        self.enabled = false
        self.sectionID = nil
        self.position = "999"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(entityID)
    }

    public static func == (lhs: EntityConfiguration, rhs: EntityConfiguration) -> Bool {
        lhs.entityID == rhs.entityID
    }
}

public class EntityConfigurationModelObject: Object {
    @Persisted var entityID: String = ""
    @Persisted var enabled: Bool = false
    @Persisted var sectionID: String?
    @Persisted var position: Int = 0

    public override class func primaryKey() -> String? {
        return "entityID"
    }

    convenience init(model: EntityConfiguration) {
        self.init()
        entityID = model.entityID
        enabled = model.enabled
        sectionID = model.sectionID
        position = Int(model.position)!
    }

}
