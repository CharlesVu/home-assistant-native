import ApplicationConfiguration
import Factory
import Foundation
import RealmSwift
import SwiftUI

class EntitySelectionViewModel: ObservableObject {
    @Injected(\.databaseManager) var databaseManager

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
        entities = Array(databaseManager.database().objects(Entity.self))
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
        try? databaseManager.database().write {
            entityAttachable.entityID = entity.id
        }
        path.wrappedValue.removeLast()
    }
}

struct EntitySelectionView: View {
    @ObservedObject var viewModel: EntitySelectionViewModel
    @State var entities: [Entity]

    init(path: Binding<NavigationPath>, entityAttachable: any EntityAttachable) {
        let entitySelectionViewModel = EntitySelectionViewModel(path: path, entityAttachable: entityAttachable)
        viewModel = entitySelectionViewModel
        entities = entitySelectionViewModel.filteredEntities
    }

    var body: some View {
        let iconMapper = Container.shared.iconMapper.callAsFunction()

        List {
            ForEach(viewModel.sections, id: \.self) { section in
                Section(section) {
                    ForEach(viewModel.entities(for: section)) { entity in
                        HStack {
                            HABasicIconView(icon: iconMapper.map(entity: entity))
                            Text(entity.displayName())
                        }.onTapGesture {
                            Task {
                                await viewModel.didSelectEntity(entity)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText)
    }
}
