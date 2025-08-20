import ApplicationConfiguration
import Combine
import HomeAssistant
import RealmSwift
import XCTest

@testable import Home_Assistant

final class homeAssistant_Tests: XCTestCase {
    var homeAssistantBrdigeSpy: HomeAssistantBridgingSpy!
    var entityStoreSpy: EntityStoringSpy!
    var octopusStoreSpy: OctopusAgileStoringSpy!
    var displayableStoreSpy: DisplayableStoringSpy!

    override func setUp() async throws {
        homeAssistantBrdigeSpy = HomeAssistantBridgingSpy()
        entityStoreSpy = EntityStoringSpy()
        octopusStoreSpy = OctopusAgileStoringSpy()
        displayableStoreSpy = DisplayableStoringSpy()

        homeAssistantBrdigeSpy.entityPublisher = .init()
        homeAssistantBrdigeSpy.entityInitialStatePublisher = .init()
        homeAssistantBrdigeSpy.octopusPublisher = .init()
    }

    func sut() -> AppDelegate {
        let sut = AppDelegate()
        sut.set(
            homeAssistant: homeAssistantBrdigeSpy,
            entityStore: entityStoreSpy,
            displayableStore: displayableStoreSpy,
            octopusStore: octopusStoreSpy
        )
        return sut
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
