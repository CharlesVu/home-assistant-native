import ApplicationConfiguration
import Factory
import Foundation
import Spyable

@Spyable
protocol OctopusAgileStoring {
    func addRates(
        _ rates: [(
            start: Date,
            end: Date,
            price: Double
        )]
    ) async

    func futureTariff() -> [OctopusRateModelObject]
}

struct OctopusAgileStore: OctopusAgileStoring {
    @Injected(\.databaseManager) var databaseManager

    @MainActor
    public func addRates(
        _ rates: [(
            start: Date,
            end: Date,
            price: Double
        )]
    ) async {
        try? await databaseManager.database().asyncWrite {
            rates.forEach {
                let rate = OctopusRateModelObject(
                    start: $0.start,
                    end: $0.end,
                    price: $0.price
                )
                databaseManager.database().add(rate, update: .modified)
            }
        }
    }

    @MainActor
    func futureTariff() -> [OctopusRateModelObject] {
        return Array(
            self.databaseManager.database()
                .objects(OctopusRateModelObject.self)
                .filter { $0.end > Date.now }
        )
    }
}
