import ApplicationConfiguration
import SwiftUI

struct EntitySelectionView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var databaseProvider: PersistantRealmProvider
    @EnvironmentObject private var iconMapper: IconMapper
    @ObservedObject var viewModel: EntitySelectionViewModel

    @State var entities: [Entity]

    init(path: Binding<NavigationPath>, entityAttachable: any EntityAttachable) {
        let entitySelectionViewModel = EntitySelectionViewModel(path: path, entityAttachable: entityAttachable)
        viewModel = entitySelectionViewModel
        entities = entitySelectionViewModel.filteredEntities
    }

    var body: some View {
        List {
            ForEach(viewModel.sections, id: \.self) { section in
                Section(section) {
                    ForEach(viewModel.entities(for: section)) { entity in
                        HStack {
                            HAWidgetImageView(
                                imageName: iconMapper.map(entity: entity),
                                color: themeManager.current.text
                            )
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
        .onAppear {
            viewModel.set(databaseProvider: databaseProvider)
        }
    }
}
