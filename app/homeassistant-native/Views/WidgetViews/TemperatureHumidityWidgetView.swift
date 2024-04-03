import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

enum StaticEntityKeys: String {
    case electricityPrice = "sensor.octopus_energy_electricity_22m0089910_1300053095531_current_accumulative_cost"
    case electricityConsumption =
        "sensor.octopus_energy_electricity_22m0089910_1300053095531_current_accumulative_consumption"
    case gasPrice = "sensor.octopus_energy_gas_e6f20446412200_9097627310_current_accumulative_cost"
    case gasConsumption = "sensor.octopus_energy_gas_e6f20446412200_9097627310_current_accumulative_consumption_kwh"
    case weather = "weather.forecast_home"
}

class TemperatureHumidityWidgetViewModel: ObservableObject {
    @Injected(\.databaseManager) private var databaseManager

    @Published var temperature: Double = 0
    @Published var humidity: Int = 0
    @Published var windSpeed: Double = 0

    @Published var electricityUsage: Double = 0
    @Published var electricityTotalPrice: Double = 0
    @Published var gasUsage: Double = 0
    @Published var gasTotalPrice: Double = 0

    var tokens: [NotificationToken] = []
    private var subscriptions = Set<AnyCancellable>()

    init() {
        if let token =
            databaseManager
            .listenForEntityChange(
                id: StaticEntityKeys.weather.rawValue,
                callback: { [weak self] entity in
                    self?.temperature = entity.temperature!
                    self?.humidity = entity.humidity!
                    self?.windSpeed = entity.windSpeed!
                }
            ) {
            tokens.append(token)
        }

        if let token =
            databaseManager
            .listenForEntityChange(
                id: StaticEntityKeys.electricityPrice.rawValue,
                callback: { [weak self] entity in
                    if let value = Double(entity.state) {
                        self?.electricityTotalPrice = value.truncate(places: 2)
                    }
                }
            ) {
            tokens.append(token)
        }

        if let token =
            databaseManager
            .listenForEntityChange(
                id: StaticEntityKeys.electricityConsumption.rawValue,
                callback: { [weak self] entity in
                    if let value = Double(entity.state) {
                        self?.electricityUsage = value.truncate(places: 2)
                    }
                }
            ) {
            tokens.append(token)
        }

        if let token =
            databaseManager
            .listenForEntityChange(
                id: StaticEntityKeys.gasConsumption.rawValue,
                callback: { [weak self] entity in
                    if let value = Double(entity.state) {
                        self?.gasUsage = value.truncate(places: 2)
                    }
                }
            ) {
            tokens.append(token)
        }

        if let token =
            databaseManager
            .listenForEntityChange(
                id: StaticEntityKeys.gasPrice.rawValue,
                callback: { [weak self] entity in
                    if let value = Double(entity.state) {
                        self?.gasTotalPrice = value.truncate(places: 2)
                    }
                }
            ) {
            tokens.append(token)
        }
    }
}

struct TemperatureHumidityWidgetView: View {
    @StateObject var viewModel: TemperatureHumidityWidgetViewModel = .init()

    var body: some View {
        ZStack {
            HStack(alignment: .top, spacing: 0) {
                HStack {
                    HAWidgetImageView(imageName: "thermometer.medium")
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
