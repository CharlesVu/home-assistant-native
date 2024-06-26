import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class ContentViewModel: ObservableObject {
    @Injected(\.displayableStore) var displayableStore
    @Published var rootViewType: HAViewType?

    init() {
        if let rootObject = displayableStore.root() {
            rootViewType = HAViewBuilder().map(model: rootObject)
        }
    }
}

struct ContentView: View {
    @State var show = false
    @ObservedObject var viewModel: ContentViewModel = .init()
    @StateObject var themeManager = Container.shared.themeManager.callAsFunction()

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
        .environmentObject(themeManager)
        .background(themeManager.current.background)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
