import Foundation
import RealmSwift

public class VStackConfiguration: Object, ObjectKeyIdentifiable {
    @Persisted public var id: String = UUID().uuidString
    @Persisted public var children: List<SectionModelObject>

    public override class func primaryKey() -> String? {
        return "id"
    }
}
