import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class ContentViewModel: ObservableObject {
    init() {}

    func buildView() -> some View {
        EmptyView()
    }
}

struct ContentView: View {
    @State var show = false
    @ObservedObject var viewModel: ContentViewModel = .init()

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            viewModel.buildView()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
