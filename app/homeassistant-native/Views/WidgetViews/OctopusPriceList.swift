import ApplicationConfiguration
import Factory
import RealmSwift
import SwiftUI

class OctopusPriceListViewModel: ObservableObject {
    @Injected(\.octopusStore) var octopusStore

    @Published var tariffs: [OctopusRateModelObject] = []
    @Published var meanPrice: Double = 0

    var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.minutes, repeats: true) { [weak self] _ in
            guard let self else { return }
            let tariffs = octopusStore.futureTariff()
            var total: Double = 0
            tariffs.forEach { total += $0.price }
            meanPrice = total / Double(tariffs.count)
            self.tariffs = tariffs
        }
        timer?.fire()
    }
}

struct OctopusPriceListView: View {
    @ObservedObject var viewModel = OctopusPriceListViewModel()

    var body: some View {
        List {
            Section("Octopus") {
                ForEach(Array(stride(from: 0, to: $viewModel.tariffs.count, by: 2)), id: \.self) { index in
                    let leftItem = viewModel.tariffs[index]
                    HStack {
                        OctopusPricingVIew(
                            date: leftItem.start,
                            price: leftItem.price,
                            meanPrice: viewModel.meanPrice
                        )

                        if index + 1 < viewModel.tariffs.count {
                            let rightItem = viewModel.tariffs[index + 1]
                            OctopusPricingVIew(
                                date: rightItem.start,
                                price: rightItem.price,
                                meanPrice: viewModel.meanPrice
                            )
                        }
                    }
                }
            }
        }
    }
}
