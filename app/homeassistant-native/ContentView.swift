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

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            if let rootViewType = viewModel.rootViewType {
                HAViewBuilder().view(viewType: rootViewType)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
