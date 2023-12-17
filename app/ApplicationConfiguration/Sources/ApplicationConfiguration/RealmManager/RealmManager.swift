import Foundation
import RealmSwift

class RealmManager {
//    private let serialQueue = DispatchQueue(label: "serial-queue")
    private let realm: Realm

    init() {
        realm = try! Realm()
    }

    func database() -> Realm {
        return realm
    }
}
