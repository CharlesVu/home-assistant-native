import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class ContentViewModel: ObservableObject {
    @Injected(\.databaseManager) var databaseManager

    @ObservedResults(
        EntityModelObject.self,
        filter: .init(format: "entityID BEGINSWITH %@ AND attributes.hueType = 'room'", "light")
    ) var lights

    @Published var tariffs: [OctopusRateModelObject] = []
    @Published var meanPrice: Double = 0

    var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.minutes, repeats: true) { [weak self] _ in
            guard let self else { return }
            let tariffs = Array(self.databaseManager.database()
                .objects(OctopusRateModelObject.self)
                .filter { $0.end > Date.now })
            var total: Double = 0
            tariffs.forEach { total += $0.price }
            meanPrice = total / Double(tariffs.count)
            self.tariffs = tariffs
        }
        timer?.fire()
    }
}

extension DateFormatter {
    static var octopusDsiplayDateFormatter: DateFormatter {
        let dateFomatter = DateFormatter()
        dateFomatter.calendar = Calendar(identifier: .iso8601)
        dateFomatter.locale = Locale(identifier: "en_US_POSIX")
        dateFomatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFomatter.dateFormat = "E HH:mm"
        return dateFomatter
    }
}

extension Date {
    var octopusFormatted: String {
        DateFormatter.octopusDsiplayDateFormatter.string(from: self)
    }
}

struct ContentView: View {
    @State var show = false
    @ObservedObject var viewModel: ContentViewModel = .init()

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            HStack {
                List {
                    Section("Octopus") {
                        ForEach(Array(stride(from: 0, to: $viewModel.tariffs.count, by: 2)), id: \.self) { index in
                            let leftItem = viewModel.tariffs[index]
                            HStack {
                                OctopusPricingVIew(date: leftItem.start, price: leftItem.price, meanPrice: viewModel.meanPrice)

                                if index + 1 < viewModel.tariffs.count {
                                    let rightItem = viewModel.tariffs[index + 1]
                                    OctopusPricingVIew(date: rightItem.start, price: rightItem.price, meanPrice: viewModel.meanPrice)
                                } else {
                                    Text(" ")
                                    Text(" ")
                                }
                            }
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
