import Foundation
import RealmSwift

public enum ButtonAlignment: String, PersistableEnum {
    case hotizontal
    case vertical
}

public enum ButtonButtonMode: String, PersistableEnum {
    case toggle
    case turnOn
    case turnOff
}

public class ButtonConfiguration: Object, ObjectKeyIdentifiable {
    @Persisted public var id: String = UUID().uuidString
    @Persisted public var entityID: String?
    @Persisted public var alignment: ButtonAlignment?
    @Persisted public var mode: ButtonButtonMode?

    public override class func primaryKey() -> String? {
        return "id"
    }
}
