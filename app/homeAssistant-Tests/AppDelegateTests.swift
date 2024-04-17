import ApplicationConfiguration
import Combine
import Factory
import HomeAssistant
import RealmSwift
import XCTest

@testable import Home_Assistant

final class homeAssistant_Tests: XCTestCase {
    let homeAssistantBrdigeSpy = HomeAssistantBridgingSpy()
    let entityStoreSpy = EntityStoringSpy()
    let octopusStoreSpy = OctopusAgileStoringSpy()
    let displayableStoreSpy = DisplayableStoringSpy()

    override func setUp() async throws {
        homeAssistantBrdigeSpy.entityPublisher = .init()
        homeAssistantBrdigeSpy.entityInitialStatePublisher = .init()
        homeAssistantBrdigeSpy.octopusPublisher = .init()

        Container.shared.homeAssistant.register { self.homeAssistantBrdigeSpy }
        Container.shared.entityStore.register { self.entityStoreSpy }
        Container.shared.octopusStore.register { self.octopusStoreSpy }
        Container.shared.displayableStore.register { self.displayableStoreSpy }
    }

    func sut() -> AppDelegate {
        AppDelegate()
    }

    func testEntityBinding() {
        let sut = sut()
        sut.bindHomeAssistantPublishers()

        let expectation = self.expectation(description: "Awaiting publisher")
        entityStoreSpy.updateEntityNewStateClosure = { state in
            expectation.fulfill()
            XCTAssertEqual(self.entityStoreSpy.updateEntityNewStateReceivedNewState, EntityState.zero)
        }

        self.homeAssistantBrdigeSpy.entityPublisher.send(EntityState.zero)
        wait(for: [expectation], timeout: 1)
    }

    func testInitialStateBiding() {
        let sut = sut()
        sut.bindHomeAssistantPublishers()

        let expectation = self.expectation(description: "Awaiting publisher")
        entityStoreSpy.updateEntitiesNewStatesClosure = { state in
            expectation.fulfill()
            XCTAssertEqual(self.entityStoreSpy.updateEntitiesNewStatesReceivedNewStates, [])
        }

        self.homeAssistantBrdigeSpy.entityInitialStatePublisher.send([])
        wait(for: [expectation], timeout: 1)
    }

    func testUpdateRatesBinding() {
        let sut = sut()
        sut.bindHomeAssistantPublishers()

        let expectation = self.expectation(description: "Awaiting publisher")
        octopusStoreSpy.addRatesClosure = { state in
            expectation.fulfill()
            XCTAssert(self.octopusStoreSpy.addRatesReceivedRates?.isEmpty == true)
        }

        self.homeAssistantBrdigeSpy.octopusPublisher.send([])
        wait(for: [expectation], timeout: 1)
    }

    func testInitialDatabasePopulation() async {
        displayableStoreSpy.rootReturnValue = nil
        let sut = sut()

        let expectation = self.expectation(description: "Awaiting publisher")
        displayableStoreSpy.createRootStackClosure = {
            expectation.fulfill()
            XCTAssertTrue(self.displayableStoreSpy.createRootStackCalled)
        }
        await sut.createInitialStateIfNeeded()
        await fulfillment(of: [expectation], timeout: 1)
    }
}
