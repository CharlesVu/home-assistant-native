import Foundation
import Factory

public class EntityConfigurationManager {
    @Injected(\.config) private var config
    @Injected(\.databaseManager) private var databaseManager

    private var entityCache: Set<EntityConfiguration> = []

    init() {
        entityCache = Set(databaseManager.database().objects(EntityConfigurationModelObject.self).map({
            EntityConfiguration(model: $0)
        }))
        notifyForChanges()
    }

    func notifyForChanges() {
        config.entityConfigurationPublisher.send(
            entityCache.sorted(by: { lhs, rhs in
                return Int(lhs.position)! < Int(rhs.position)!
            })
        )
    }

    public func addConfiguration(_ entityConfigration: EntityConfiguration) async throws {
        try await databaseManager.database().asyncWrite {
            databaseManager.database().add(EntityConfigurationModelObject(model: entityConfigration), update: .modified)
        }
        entityCache.insert(entityConfigration)
        notifyForChanges()
    }

    public func removeConfiguration(_ entityConfigration: EntityConfiguration) async throws {
        try await databaseManager.database().asyncWrite {
            databaseManager.database().delete(EntityConfigurationModelObject(model: entityConfigration))
        }
        entityCache.remove(entityConfigration)
        notifyForChanges()
    }
}
