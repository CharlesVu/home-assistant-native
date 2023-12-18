import Factory
import Foundation

public class SectionManager {
    @Injected(\.config) private var config
    @Injected(\.databaseManager) private var databaseManager

    private var sectionCache: Set<SectionInformation> = []

    init() {
        sectionCache = Set(
            databaseManager.database().objects(SectionModelObject.self).map({
                SectionInformation(model: $0)
            })
        )
        notifyForChanges()
    }

    func notifyForChanges() {
        config.sectionPublisher.send(
            sectionCache.sorted(by: { lhs, rhs in
                return lhs.name < rhs.name
            })
        )
    }

    public func addSection(_ section: SectionInformation) async throws {
        try await databaseManager.database().asyncWrite {
            databaseManager.database().add(SectionModelObject(model: section), update: .modified)
        }
        sectionCache.insert(section)
        notifyForChanges()
    }

    public func removeSection(_ section: SectionInformation) async throws {
        try await databaseManager.database().asyncWrite {
            databaseManager.database().delete(SectionModelObject(model: section))
        }
        sectionCache.remove(section)
        notifyForChanges()
    }
}
