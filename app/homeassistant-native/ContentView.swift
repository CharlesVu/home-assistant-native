import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class ContentViewModel: ObservableObject {
    @ObservedResults(
        Entity.self,
        filter: .init(format: "entityID BEGINSWITH %@ AND attributes.hueType = 'room'", "light")
    ) var lights
}


struct ContentView: View {
    @State var show = false
    @ObservedObject var viewModel: ContentViewModel = .init()

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            HStack {
//                OctopusPriceListView()
                List {
                    Section("Test") {
                        HAButton(entityID: "light.charles_key_light")
                    }
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
