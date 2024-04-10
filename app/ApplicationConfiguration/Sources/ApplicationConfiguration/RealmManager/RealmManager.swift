import Combine
import Foundation
import OSLog
import RealmSwift

public class RealmManager {
    private let realm: Realm
    let messageLogger = Logger(subsystem: "Realm", category: "Realm")

    init() {
        let configuration = Realm.Configuration(schemaVersion: 13)
        realm = try! Realm(configuration: configuration)
        if let path = realm.configuration.fileURL?.absoluteString {
            messageLogger.debug("Realm Path \(path)")
        }
    }

    public func database() -> Realm {
        return realm
    }
}
