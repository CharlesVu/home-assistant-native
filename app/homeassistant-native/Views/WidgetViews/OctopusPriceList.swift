import ApplicationConfiguration
import RealmSwift
import SwiftUI

class OctopusPriceListViewModel: ObservableObject {

    @Published var tariffs: [OctopusRateModelObject] = []
    @Published var meanPrice: Double = 0

    var timer: Timer?

    func set(octopusStore: OctopusAgileStore) {
        timer = Timer.scheduledTimer(withTimeInterval: 5.minutes, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task {
                let tariffs = await octopusStore.futureTariff()
                var total: Double = 0
                tariffs.forEach { total += $0.price }
                self.meanPrice = total / Double(tariffs.count)
                self.tariffs = tariffs
            }
        }
        timer?.fire()
    }
}

struct OctopusPriceListView: View {
    @ObservedObject var viewModel = OctopusPriceListViewModel()

    var body: some View {
        ForEach(Array(stride(from: 0, to: $viewModel.tariffs.count, by: 2)), id: \.self) { index in
            let leftItem = viewModel.tariffs[index]
            HStack {
                OctopusPricingView(
                    date: leftItem.start,
                    price: leftItem.price,
                    meanPrice: viewModel.meanPrice
                )

                if index + 1 < viewModel.tariffs.count {
                    let rightItem = viewModel.tariffs[index + 1]
                    OctopusPricingView(
                        date: rightItem.start,
                        price: rightItem.price,
                        meanPrice: viewModel.meanPrice
                    )
                }
            }
        }
    }
}
