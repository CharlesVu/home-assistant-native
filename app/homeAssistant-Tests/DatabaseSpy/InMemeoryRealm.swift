import ApplicationConfiguration
import Combine
import Foundation
import OSLog
import RealmSwift

public class InMemeoryRealm: RealmProvider {
    private let realm: Realm
    let messageLogger = Logger(subsystem: "Realm", category: "Realm")

    @MainActor
    init() {
        let configuration = Realm.Configuration(
            inMemoryIdentifier: UUID().uuidString
        )
        realm = try! Realm(configuration: configuration)
    }

    public func database() -> Realm {
        return realm
    }
}
