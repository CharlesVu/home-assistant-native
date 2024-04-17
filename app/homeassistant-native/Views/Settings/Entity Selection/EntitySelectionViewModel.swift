import ApplicationConfiguration
import Factory
import Foundation
import RealmSwift
import SwiftUI

class EntitySelectionViewModel: ObservableObject {
    @Injected(\.databaseProvider) var databaseProvider

    var entities = [Entity]()
    @Published var sections = [String]()
    @Published var searchText: String = "" {
        didSet {
            refresh()
        }
    }
    @Published var filteredEntities = [Entity]()

    var entityAttachable: any EntityAttachable
    var path: Binding<NavigationPath>

    func refresh() {
        filterEntities()
        sections = Array(Set(filteredEntities.compactMap { $0.id.components(separatedBy: ".").first })).sorted()
    }

    init(path: Binding<NavigationPath>, entityAttachable: any EntityAttachable) {
        self.path = path
        self.entityAttachable = entityAttachable
        entities = Array(databaseProvider.database().objects(Entity.self))
        refresh()
    }

    func filterEntities() {
        if searchText != "" {
            filteredEntities = entities.filter {
                $0.displayName().lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredEntities = entities
        }
    }

    func entities(`for` section: String) -> [Entity] {
        return filteredEntities.filter {
            $0.id.components(separatedBy: ".").first == section
        }
    }

    @MainActor
    func didSelectEntity(_ entity: Entity) async {
        try? databaseProvider.database().write {
            entityAttachable.entityID = entity.id
        }
        path.wrappedValue.removeLast()
    }
}
