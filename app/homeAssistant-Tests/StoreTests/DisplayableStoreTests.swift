import ApplicationConfiguration
import Combine
import HomeAssistant
import RealmSwift
import XCTest

@testable import Home_Assistant

final class DisplayableStore_Tests: XCTestCase {
    var inMemoryRealm: InMemeoryRealmProvider!

    @MainActor
    override func setUp() async throws {
        inMemoryRealm = .init()
    }

    func sut() -> DisplayableStore {
        return DisplayableStore(databaseProvider: inMemoryRealm)
    }

    @MainActor
    func test_rootReturnCorrectObject() async throws {
        let id = "MyStack"

        let configuration = StackConfiguration()
        let newStackObject = DisplayableModelObject()
        newStackObject.id = id
        newStackObject.type = .stack
        newStackObject.configurationID = configuration.id
        let db = inMemoryRealm.database()

        try inMemoryRealm.database().write {
            db.add(configuration)
            db.add(newStackObject)
        }
        let rootStack = await sut().root()

        XCTAssertEqual(rootStack, newStackObject)
        XCTAssertEqual(id, newStackObject.id)
    }

    @MainActor
    func test_createRootStack() async throws {
        await sut().createRootStack()
        let db = inMemoryRealm.database()

        XCTAssertEqual(1, db.objects(StackConfiguration.self).count)
        XCTAssertEqual(1, db.objects(DisplayableModelObject.self).count)

        let rootDsiplayable = db.objects(DisplayableModelObject.self).first
        let rootConfiguration = db.objects(StackConfiguration.self).first

        XCTAssertNil(rootDsiplayable?.parentSection)
        XCTAssertNotNil(rootDsiplayable?.configurationID)
        XCTAssertEqual(rootDsiplayable?.configurationID, rootConfiguration?.id)
        XCTAssertEqual(rootDsiplayable?.type, .stack)
    }
}
