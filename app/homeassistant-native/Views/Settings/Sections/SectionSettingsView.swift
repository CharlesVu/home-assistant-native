import ApplicationConfiguration
import Combine
import RealmSwift
import SwiftUI

class RootConfigurationViewModel: ObservableObject {
    @Published var rootViewType: SettingDestination?

    func set(
        displayableStore: any DisplayableStoring,
        entityStore: EntityStore
    ) {

        Task { @MainActor in
            if let rootObject = await displayableStore.root() {
                let rootViewType = await HAVSettingsViewBuilder(
                    entityStore: entityStore,
                    displayableStore: displayableStore
                ).map(model: rootObject)
                self.rootViewType = rootViewType
            }
        }
    }
}

struct RootConfigurationView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var displayableStore: DisplayableStore
    @EnvironmentObject private var entityStore: EntityStore

    @ObservedObject var viewModel: RootConfigurationViewModel = .init()
    var path: Binding<NavigationPath>

    var body: some View {
        List {
            if let rootViewType = viewModel.rootViewType {
                HAVSettingsViewBuilder(entityStore: entityStore, displayableStore: displayableStore).view(
                    viewType: rootViewType
                )
                .listRowBackground(themeManager.current.lightBackground)
            }
        }
        .background(themeManager.current.background)
        .scrollContentBackground(.hidden)
        .onAppear {
            viewModel.set(displayableStore: displayableStore, entityStore: entityStore)
        }
    }
}
