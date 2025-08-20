import ApplicationConfiguration
import Combine
import RealmSwift
import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var rootViewType: HAViewType?

    func set(displayableStore: any DisplayableStoring) {
        Task { @MainActor in
            if let rootObject = await displayableStore.root() {
                rootViewType = HAViewBuilder().map(model: rootObject)
            }
        }
    }
}

struct ContentView: View {
    @State var show = false
    @ObservedObject var viewModel: ContentViewModel = .init()
    @EnvironmentObject var displayableStore: DisplayableStore
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            ScrollView {
                if let rootViewType = viewModel.rootViewType {
                    HAViewBuilder().view(viewType: rootViewType)
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
        }
        .background(themeManager.current.background)
        .onAppear {
            viewModel.set(displayableStore: displayableStore)
        }
    }
}
