import Combine
import RealmSwift

public protocol RealmProviding: ObservableObject {
    func database() -> Realm
}
