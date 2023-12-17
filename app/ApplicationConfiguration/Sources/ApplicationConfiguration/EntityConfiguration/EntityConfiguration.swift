import Foundation
import RealmSwift

public class EntityConfiguration: Object {
    @Persisted var entityID: String = ""
    @Persisted var enabled: Bool = false
    @Persisted var sectionID: String? = ""
    @Persisted var position: Int = 0

    public override class func primaryKey() -> String? {
        return "entityID"
    }
}
