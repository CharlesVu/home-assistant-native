//
//  TemperatureHumidityWidgetView.swift
//  homeassistant-native
//
//  Created by santoru on 25/12/21.
//

import SwiftUI
import Combine
import Factory

class TemperatureHumidityWidgetViewModel: ObservableObject {
    @Injected(\.websocket) private var websocket

    @Published var temperature: Double = 0
    @Published var humidity: Int = 0
    @Published var windSpeed: Double = 0
    
    @Published var electricityUsage: Double = 0
    @Published var electricityTotalPrice: Double = 0
    @Published var gasUsage: Double = 0
    @Published var gasTotalPrice: Double = 0

    private var subscriptions = Set<AnyCancellable>()

    init() {
        websocket.subject
        .filter { $0.entityId == "weather.forecast_home" }
        .receive(on: DispatchQueue.main)
        .sink {
            self.temperature = $0.attributes.temperature!
            self.humidity = $0.attributes.humidity!
            self.windSpeed = $0.attributes.windSpeed!
        }
        .store(in: &subscriptions)

        websocket.subject
        .filter {
            $0.entityId == "sensor.octopus_energy_electricity_22m0089910_1300053095531_current_accumulative_consumption" ||
            $0.entityId == "sensor.octopus_energy_electricity_22m0089910_1300053095531_current_accumulative_cost" ||
            $0.entityId == "sensor.octopus_energy_gas_e6f20446412200_9097627310_current_accumulative_consumption" ||
            $0.entityId == "sensor.octopus_energy_gas_e6f20446412200_9097627310_current_accumulative_cost"
        }
        .receive(on: DispatchQueue.main)
        .sink {
            if $0.entityId == "sensor.octopus_energy_electricity_22m0089910_1300053095531_current_accumulative_consumption" {
                self.electricityUsage = Double($0.state)!.truncate(places: 2)
            } else if $0.entityId == "sensor.octopus_energy_electricity_22m0089910_1300053095531_current_accumulative_cost" {
                self.electricityTotalPrice = Double($0.state)!.truncate(places: 2)
            } else if $0.entityId == "sensor.octopus_energy_gas_e6f20446412200_9097627310_current_accumulative_consumption" {
                self.gasUsage = Double($0.state)!.truncate(places: 2)
            } else if $0.entityId == "sensor.octopus_energy_gas_e6f20446412200_9097627310_current_accumulative_cost" {
                self.gasTotalPrice = Double($0.state)!.truncate(places: 2)
            }
        }
        .store(in: &subscriptions)

    }
}

struct TemperatureHumidityWidgetView: View {
    @StateObject var viewModel: TemperatureHumidityWidgetViewModel

    var body: some View {
        ZStack {
            HStack(alignment: .top, spacing: 0) {
                HStack {
                    HAWidgetImageView(imageName: "thermometer")
                    VStack {
                        HAMainTextView(text: "\(viewModel.temperature) °C")
                        HAFootNoteView(text: "Temperature")
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                HStack {
                    HAWidgetImageView(imageName: "humidity.fill")
                    VStack {
                        HAMainTextView(text: "\(viewModel.humidity)%")
                        HAFootNoteView(text: "Humidity")
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                HStack {
                    HAWidgetImageView(imageName: "wind")
                    VStack {
                        HAMainTextView(text: "\(viewModel.windSpeed) km/h")
                        HAFootNoteView(text: "Wind Speed")
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                HStack {
                    HAWidgetImageView(imageName: "bolt.fill")
                    VStack {
                        HAMainTextView(text: "\(viewModel.electricityUsage) kW")
                        HAFootNoteView(text: "£\(viewModel.electricityTotalPrice)")
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                HStack {
                    HAWidgetImageView(imageName: "heat.waves")
                    VStack {
                        HAMainTextView(text: "\(viewModel.gasUsage) kW")
                        HAFootNoteView(text: "£\(viewModel.gasTotalPrice)")
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            }
            .padding()
        }
    }
}

struct TemperatureHumidityWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        TemperatureHumidityWidgetView(viewModel: .init())
    }
}
