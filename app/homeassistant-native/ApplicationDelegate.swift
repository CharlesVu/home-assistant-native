import ApplicationConfiguration
import Combine
import Factory
import Foundation
import HomeAssistant
import RealmSwift
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    @Injected(\.homeAssistant) private var homeAssistant
    @Injected(\.octopusStore) private var octopusStore
    @Injected(\.entityStore) private var entityStore

    var subscriptions = Set<AnyCancellable>()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        homeAssistant
            .entityPublisher
            .sink { [weak self] entityState in
                Task {
                    await self?.entityStore.updateEntity(newState: entityState)
                }
            }
            .store(in: &subscriptions)

        homeAssistant
            .entityInitialStatePublisher
            .sink { [weak self] newStates in
                Task {
                    await self?.entityStore.updateEntities(newStates: newStates)
                }
            }
            .store(in: &subscriptions)

        homeAssistant
            .octopusPublisher
            .sink { [weak self] rates in
                self?.updateRates(newRates: rates)
            }
            .store(in: &subscriptions)

        return true
    }

    @MainActor
    func updateRates(newRates: [OctopusRate]) {
        print("Updated Octupus Rates")
        let rates = newRates.map { (start: $0.start, end: $0.end, price: $0.value) }

        Task {
            await octopusStore.addRates(rates)
        }
    }
}
