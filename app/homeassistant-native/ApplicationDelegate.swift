import ApplicationConfiguration
import Combine
import Foundation
import HomeAssistant
import RealmSwift
import UIKit

class AppDelegate {
    private var homeAssistant: (any HomeAssistantBridging)!
    private var entityStore: (any EntityStoring)!
    private var displayableStore: (any DisplayableStoring)!
    private var octopusStore: (any OctopusAgileStoring)!

    private var subscriptions = Set<AnyCancellable>()

    func set(
        homeAssistant: any HomeAssistantBridging,
        entityStore: any EntityStoring,
        displayableStore: any DisplayableStoring,
        octopusStore: any OctopusAgileStoring
    ) {
        self.homeAssistant = homeAssistant
        self.entityStore = entityStore
        self.displayableStore = displayableStore
        self.octopusStore = octopusStore

        bindHomeAssistantPublishers()

        Task {
            await createInitialStateIfNeeded()
        }
    }

    func bindHomeAssistantPublishers() {
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
                Task {
                    await self?.updateRates(newRates: rates)
                }
            }
            .store(in: &subscriptions)
    }

    @MainActor
    func createInitialStateIfNeeded() async {
        if await displayableStore.root() == nil {
            await displayableStore.createRootStack()
        }
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
