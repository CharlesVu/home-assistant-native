import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class RootConfigurationViewModel: ObservableObject {
    @Injected(\.displayableStore) var displayableStore

    @Published var rootViewType: SettingDestination?

    init() {
        if let rootObject = displayableStore.root() {
            Task {
                let rootViewType = await HAVSettingsViewBuilder().map(model: rootObject)
                DispatchQueue.main.async {
                    self.rootViewType = rootViewType
                }
            }
        }
    }
}

struct RootConfigurationView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    @ObservedObject var viewModel: RootConfigurationViewModel = .init()
    var path: Binding<NavigationPath>

    var body: some View {
        List {
            if let rootViewType = viewModel.rootViewType {
                HAVSettingsViewBuilder().view(viewType: rootViewType)
                    .listRowBackground(themeManager.current.lightBackground)
            }
        }
        .background(themeManager.current.background)
        .scrollContentBackground(.hidden)
    }
}
