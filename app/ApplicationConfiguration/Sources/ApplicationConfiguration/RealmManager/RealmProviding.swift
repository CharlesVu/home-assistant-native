import RealmSwift

public protocol RealmProviding {
    func database() -> Realm
}
