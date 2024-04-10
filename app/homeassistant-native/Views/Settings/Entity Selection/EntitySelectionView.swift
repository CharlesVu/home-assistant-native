import ApplicationConfiguration
import Factory
import SwiftUI

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
