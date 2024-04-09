import Foundation
import RealmSwift

public enum ViewType: String, PersistableEnum {
    case vStack
    //    case hStack
    case button
    //    case entity
    //    case gauge
}

public class SectionModelObject: Object, ObjectKeyIdentifiable {
    @Persisted public var id: String = UUID().uuidString
    @Persisted public var parentSection: String?
    @Persisted public var type: ViewType
    @Persisted public var configurationID: String
    @Persisted public var name: String = ""

    public override class func primaryKey() -> String? {
        return "id"
    }
}
