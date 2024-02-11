import Foundation
import RealmSwift

public class SectionModelObject: Object, ObjectKeyIdentifiable {
    @Persisted public var id: String = UUID().uuidString
    @Persisted public var name: String = ""
    @Persisted public var parentSection: String = ""

    public override class func primaryKey() -> String? {
        return "id"
    }
}
