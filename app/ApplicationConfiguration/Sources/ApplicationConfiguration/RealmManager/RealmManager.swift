import Foundation
import RealmSwift

class RealmManager {
    private let realm: Realm

    init() {
        let configuration = Realm.Configuration(schemaVersion: 3)
        realm = try! Realm(configuration: configuration)
    }

    func database() -> Realm {
        return realm
    }
}
