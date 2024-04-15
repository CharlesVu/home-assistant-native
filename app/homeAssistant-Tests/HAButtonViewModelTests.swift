import ApplicationConfiguration
import Combine
import Factory
import HomeAssistant
import RealmSwift
import XCTest

@testable import Home_Assistant

final class HAButtonViewModel_Tests: XCTestCase {
    let homeAssistantBrdigeSpy = HomeAssistantBridgingSpy()
    let entityStoreSpy = EntityStoringSpy()
    let displayableStoreSpy = DisplayableStoringSpy()

    override func setUp() async throws {

        Container.shared.homeAssistant.register { self.homeAssistantBrdigeSpy }
        Container.shared.entityStore.register { self.entityStoreSpy }
        Container.shared.displayableStore.register { self.displayableStoreSpy }
    }

    func sut() -> HAButtonViewModel {
        return HAButtonViewModel(displayableModelObjectID: "")
    }

    func test_ObserveConfigurationChanges() {
        displayableStoreSpy.buttonConfigurationDisplayableModelObjectIDReturnValue = .init()

        let sut = sut()

        let expectation = self.expectation(description: "Awaiting publisher")

        displayableStoreSpy.observeOnChangeOnDeleteClosure = { (object, onChange, onDelete) -> NotificationToken? in
            expectation.fulfill()
            return .init()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_WhenConfigurationIsDeleted_ThenObserbverTokenIsNil() async {
        displayableStoreSpy.buttonConfigurationDisplayableModelObjectIDReturnValue = .init()
        let sut = sut()

        let expectation = self.expectation(description: "Awaiting publisher")

        displayableStoreSpy.observeOnChangeOnDeleteClosure = { (object, onChange, onDelete) -> NotificationToken? in
            Task {
                await onDelete?()
                XCTAssertNil(sut.configuration)
                XCTAssertNil(sut.configurationObserverToken)
                expectation.fulfill()
            }
            return .init()
        }

        await fulfillment(of: [expectation], timeout: 1)
    }

    func test_WhenConfigurationIsChanged_ThenConfigurationModelIsChanged() async {
        let buttonConfiguration = ButtonConfiguration()
        buttonConfiguration.entityID = "oldID"
        buttonConfiguration.alignment = .horizontal
        buttonConfiguration.mode = .toggle

        displayableStoreSpy.buttonConfigurationDisplayableModelObjectIDReturnValue = buttonConfiguration
        entityStoreSpy.listenForEntityChangeIdOnChangeOnDeleteReturnValue = .init()

        let sut = sut()
        let expectation = self.expectation(description: "Awaiting publisher")

        displayableStoreSpy.observeOnChangeOnDeleteClosure = { (object, onChange, onDelete) -> NotificationToken? in
            Task {
                // Check the initial State
                await onChange()
                XCTAssertEqual(sut.alignment, .horizontal)
                XCTAssertEqual(sut.buttonMode, .toggle)
                XCTAssertTrue(
                    self.entityStoreSpy.listenForEntityChangeIdOnChangeOnDeleteReceivedArguments?.id == "oldID"
                )

                // Modify the state
                buttonConfiguration.entityID = "newID"
                buttonConfiguration.alignment = .vertical
                buttonConfiguration.mode = .turnOn
                await onChange()

                // Check the modified State
                XCTAssertEqual(sut.alignment, .vertical)
                XCTAssertEqual(sut.buttonMode, .turnOn)
                XCTAssertTrue(
                    self.entityStoreSpy.listenForEntityChangeIdOnChangeOnDeleteReceivedArguments?.id == "newID"
                )
                expectation.fulfill()

            }
            return .init()
        }

        await fulfillment(of: [expectation], timeout: 1)
    }
}
