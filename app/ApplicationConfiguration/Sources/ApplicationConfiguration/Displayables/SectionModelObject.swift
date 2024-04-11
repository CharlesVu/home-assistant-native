import Foundation
import RealmSwift

public enum ViewType: String, PersistableEnum {
    case stack
    case button
    case stateDisplay
    //    case gauge
    case octopus
}

public class DisplayableModelObject: Object, ObjectKeyIdentifiable {
    @Persisted public var id: String = UUID().uuidString
    @Persisted public var parentSection: String?
    @Persisted public var type: ViewType
    @Persisted public var configurationID: String = ""
    @Persisted public var name: String = ""

    public override class func primaryKey() -> String? {
        return "id"
    }
}
