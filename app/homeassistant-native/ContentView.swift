import Combine
import Factory
import SwiftUI

class ContentViewModel: ObservableObject {
    @Injected(\.websocket) private var websocket

    let headerViewModel: HeaderViewModel
    var subscriptions = Set<AnyCancellable>()

    @Published var carItems = Set<EntityState>()
    @Published var lights = Set<EntityState>()

    init() {
        headerViewModel = HeaderViewModel()

        websocket
            .entityPublisher
            .filter {
                $0.entityId == "binary_sensor.ioniq_5_ev_battery_charge"
                    || $0.entityId == "sensor.ioniq_5_ev_battery_level"
                    || $0.entityId == "binary_sensor.ioniq_5_ev_charge_port"
                    || $0.entityId == "sensor.ioniq_5_car_battery_level" || $0.entityId == "lock.ioniq_5_door_lock"
            }
            .sink { self.carItems.insert($0) }
            .store(in: &subscriptions)

        websocket
            .entityPublisher
            .filter {
                $0.entityId.hasPrefix("light") && $0.attributes.hueType == "room"
            }
            .sink { self.lights.insert($0) }
            .store(in: &subscriptions)
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
                    Section("IONIQ 5") {
                        ForEach(Array(viewModel.carItems)) { item in
                            SimpleStateWidget(
                                initialState: item
                            )
                        }
                    }
                }

                List {
                    Section("Lights") {
                        ForEach(Array(viewModel.lights)) { item in
                            SwitchWidgetListView(
                                initialState: item
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
