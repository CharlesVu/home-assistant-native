import Foundation
import OSLog
import RealmSwift
import Combine

public class RealmManager {
    private let realm: Realm
    let messageLogger = Logger(subsystem: "Realm", category: "Realm")

    init() {
        let configuration = Realm.Configuration(schemaVersion: 8)
        realm = try! Realm(configuration: configuration)
        if let path = realm.configuration.fileURL?.absoluteString {
            messageLogger.debug("Realm Path \(path)")
        }
    }

    public func database() -> Realm {
        return realm
    }

    public func listenForEntityChange(
        id: String,
        callback: @escaping (Entity) -> Void
    ) -> NotificationToken? {
        let entityObject = database()
            .object(ofType: EntityModelObject.self, forPrimaryKey: id)
        
        if let entityObject {
            callback(Entity(projecting: entityObject))
        }

        return entityObject?
            .observe({ changes in
                switch changes {
                    case .change(let object, _):
                        if let obj = object as? EntityModelObject {
                            callback(Entity(projecting: obj))
                        }
                    default:
                        ()
                }
            })
    }
}
