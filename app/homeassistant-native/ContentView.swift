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

    @ObservedResults(
        Entity.self
    ) var allEntities

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
                        HStack {
                            HAButton(entityID: "light.charles_key_light")
                            HAButton(entityID: "sensor.bathroom_sensor_humidity")
                        }
                        ForEach(Array(viewModel.allEntities)) {
                            HAEntityView(entityID: $0.id)
                        }

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
