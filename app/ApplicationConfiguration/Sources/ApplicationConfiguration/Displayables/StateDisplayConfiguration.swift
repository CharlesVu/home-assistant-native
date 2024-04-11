import Foundation
import RealmSwift

public enum StateDisplayAlignment: String, PersistableEnum {
    case horizontal
    case vertical
}

public class StateDisplayConfiguration: Object, ObjectKeyIdentifiable {
    @Persisted public var id: String = UUID().uuidString
    @Persisted public var entityID: String?
    @Persisted public var alignment: StateDisplayAlignment = .horizontal

    public override class func primaryKey() -> String? {
        return "id"
    }
}
