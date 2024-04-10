import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

enum StaticEntityKeys: String {
    case electricityPrice =
        "sensor.octopus_energy_electricity_22m0089910_1300053095531_current_accumulative_cost"
    case electricityConsumption =
        "sensor.octopus_energy_electricity_22m0089910_1300053095531_current_accumulative_consumption"
    case gasPrice = "sensor.octopus_energy_gas_e6f20446412200_9097627310_current_accumulative_cost"
    case gasConsumption =
        "sensor.octopus_energy_gas_e6f20446412200_9097627310_current_accumulative_consumption_kwh"
    case weather = "weather.forecast_home"
}

class TemperatureHumidityWidgetViewModel: ObservableObject {
    @Injected(\.entityStore) private var entityStore

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
            entityStore
            .listenForEntityChange(
                id: StaticEntityKeys.weather.rawValue,
                callback: { [weak self] entity in
                    if let t = entity.temperature {
                        self?.temperature = t
                    }
                    if let h = entity.humidity {
                        self?.humidity = h
                    }
                    if let w = entity.windSpeed {
                        self?.windSpeed = w
                    }
                }
            )
        {
            tokens.append(token)
        }

        if let token =
            entityStore
            .listenForEntityChange(
                id: StaticEntityKeys.electricityPrice.rawValue,
                callback: { [weak self] entity in
                    if let value = Double(entity.state) {
                        self?.electricityTotalPrice = value.truncate(places: 2)
                    }
                }
            )
        {
            tokens.append(token)
        }

        if let token =
            entityStore
            .listenForEntityChange(
                id: StaticEntityKeys.electricityConsumption.rawValue,
                callback: { [weak self] entity in
                    if let value = Double(entity.state) {
                        self?.electricityUsage = value.truncate(places: 2)
                    }
                }
            )
        {
            tokens.append(token)
        }

        if let token =
            entityStore
            .listenForEntityChange(
                id: StaticEntityKeys.gasConsumption.rawValue,
                callback: { [weak self] entity in
                    if let value = Double(entity.state) {
                        self?.gasUsage = value.truncate(places: 2)
                    }
                }
            )
        {
            tokens.append(token)
        }

        if let token =
            entityStore
            .listenForEntityChange(
                id: StaticEntityKeys.gasPrice.rawValue,
                callback: { [weak self] entity in
                    if let value = Double(entity.state) {
                        self?.gasTotalPrice = value.truncate(places: 2)
                    }
                }
            )
        {
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
                        HAFootNoteView(text: "Temperature", alignement: .leading)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                HStack {
                    HAWidgetImageView(imageName: "humidity.fill")
                    VStack {
                        HAMainTextView(text: "\(viewModel.humidity)%")
                        HAFootNoteView(text: "Humidity", alignement: .leading)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                HStack {
                    HAWidgetImageView(imageName: "wind")
                    VStack {
                        HAMainTextView(text: "\(viewModel.windSpeed) km/h")
                        HAFootNoteView(text: "Wind Speed", alignement: .leading)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                HStack {
                    HAWidgetImageView(imageName: "bolt.fill")
                    VStack {
                        HAMainTextView(text: "\(viewModel.electricityUsage) kW")
                        HAFootNoteView(text: "£\(viewModel.electricityTotalPrice)", alignement: .leading)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                HStack {
                    HAWidgetImageView(imageName: "heat.waves")
                    VStack {
                        HAMainTextView(text: "\(viewModel.gasUsage) kW")
                        HAFootNoteView(text: "£\(viewModel.gasTotalPrice)", alignement: .leading)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            }
            .padding()
        }
    }
}
