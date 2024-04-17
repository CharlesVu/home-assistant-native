import Combine
import Foundation
import OSLog
import RealmSwift

public class PersistantRealmProvider: RealmProviding {
    private let realm: Realm
    let messageLogger = Logger(subsystem: "Realm", category: "Realm")

    init() {
        let configuration = Realm.Configuration(schemaVersion: 14)
        realm = try! Realm(configuration: configuration)
        if let path = realm.configuration.fileURL?.absoluteString {
            messageLogger.debug("Realm Path \(path)")
        }
    }

    public func database() -> Realm {
        return realm
    }
}
