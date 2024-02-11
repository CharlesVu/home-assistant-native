import Foundation
import OSLog
import RealmSwift

public class RealmManager {
    private let realm: Realm
    let messageLogger = Logger(subsystem: "Realm", category: "Realm")

    init() {
        let configuration = Realm.Configuration(schemaVersion: 4)
        realm = try! Realm(configuration: configuration)
        if let path = realm.configuration.fileURL?.absoluteString {
            messageLogger.debug("\(path)")
        }
    }

    public func database() -> Realm {
        return realm
    }

    public func listenForEntityChange(
        id: String,
        callback: @escaping (EntityModelObject) -> Void
    ) -> NotificationToken? {
        return database()
            .object(ofType: EntityModelObject.self, forPrimaryKey: id)?
            .observe({ changes in
                switch changes {
                    case .change(let object, _):
                        if let obj = object as? EntityModelObject {
                            callback(obj)
                        }
                    default:
                        ()
                }
            })
    }
}
