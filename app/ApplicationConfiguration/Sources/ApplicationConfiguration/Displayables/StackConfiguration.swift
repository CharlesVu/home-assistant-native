import Foundation
import RealmSwift

public enum StackAlignment: String, PersistableEnum {
    case horizontal
    case vertical
}

public class StackConfiguration: Object, ObjectKeyIdentifiable {
    @Persisted public var id: String = UUID().uuidString
    @Persisted public var children: List<DisplayableModelObject>
    @Persisted public var alignment: StackAlignment = .horizontal

    public override class func primaryKey() -> String? {
        return "id"
    }
}
