import Combine
import Factory
import ApplicationConfiguration
import SwiftUI
import RealmSwift


class ContentViewModel: ObservableObject {
    @ObservedResults(EntityModelObject.self, filter: .init(format: "entityID BEGINSWITH %@ AND attributes.hueType = 'room'", "light")) var lights

    let headerViewModel: HeaderViewModel
    var subscriptions = Set<AnyCancellable>()

    init() {
        headerViewModel = HeaderViewModel()
    }
}

struct ContentView: View {
    @State var show = false
    @ObservedObject var viewModel: ContentViewModel = .init()

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(viewModel: viewModel.headerViewModel)
            HStack {
                List {
                }

                List {
                    Section("Lights") {
                        ForEach(Array(viewModel.lights)) { item in
                            SwitchWidgetListView(
                                entity: item
                            )
                        }
                    }
                }
            }
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


