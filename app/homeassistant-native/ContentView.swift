//
//  ContentView.swift
//  homeassistant-native
//
//  Created by santoru on 24/12/21.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    let widgetDataSource = WidgetDataSource()
    let headerViewModel: HeaderViewModel
    var subscriptions = Set<AnyCancellable>()

    @Published var carItems = Set<EntityState>()
    @Published var lights = Set<EntityState>()

    init() {
        headerViewModel = HeaderViewModel(subject: widgetDataSource.subject)

        widgetDataSource
            .subject
            .filter {
                $0.entityId == "binary_sensor.ioniq_5_ev_battery_charge" ||
                $0.entityId == "sensor.ioniq_5_ev_battery_level" ||
                $0.entityId == "binary_sensor.ioniq_5_ev_charge_port" ||
                $0.entityId == "sensor.ioniq_5_car_battery_level" ||
                $0.entityId == "lock.ioniq_5_door_lock"
            }
            .sink { self.carItems.insert($0) }
            .store(in: &subscriptions)
        
        widgetDataSource
            .subject
            .filter {
                $0.entityId == "switch.pond_pump_switch" 
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
                            SimpleStateWidget(viewModel: .init(
                                initialState: item,
                                subject: viewModel.widgetDataSource.subject
                            ))
                        }
                    }
                }
                
                List {
                    Section("Lights") {
                        ForEach(Array(viewModel.lights)) { item in
                            SimpleStateWidget(viewModel: .init(
                                initialState: item,
                                subject: viewModel.widgetDataSource.subject
                            ))
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
