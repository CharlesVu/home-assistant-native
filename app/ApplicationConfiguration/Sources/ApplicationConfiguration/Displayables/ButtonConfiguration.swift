import Foundation
import RealmSwift

public enum ButtonAlignment: String, PersistableEnum {
    case horizontal
    case vertical
}

public enum ButtonMode: String, PersistableEnum {
    case toggle
    case turnOn = "Turn On"
    case turnOff = "Turn Off"
}

public class ButtonConfiguration: Object, ObjectKeyIdentifiable {
    @Persisted public var id: String = UUID().uuidString
    @Persisted public var entityID: String?
    @Persisted public var alignment: ButtonAlignment = .horizontal
    @Persisted public var mode: ButtonMode = .toggle

    public override class func primaryKey() -> String? {
        return "id"
    }
}
