import ApplicationConfiguration
import Factory
import Foundation

protocol DisplayableStoring {
    func root() -> DisplayableModelObject?

    func vStackConfiguration(displayableModelObjectID: String) -> VStackConfiguration
    func buttonConfiguration(displayableModelObjectID: String) -> ButtonConfiguration
}

struct DisplayableStore: DisplayableStoring {
    @Injected(\.databaseManager) private var databaseManager

    @MainActor
    func root() -> DisplayableModelObject? {
        return databaseManager.database().objects(DisplayableModelObject.self).filter({
            $0.parentSection == nil
        }).first
    }

    @MainActor
    func vStackConfiguration(displayableModelObjectID: String) -> VStackConfiguration {
        let displayable = databaseManager.database().object(
            ofType: DisplayableModelObject.self,
            forPrimaryKey: displayableModelObjectID
        )!
        return databaseManager.database().object(
            ofType: VStackConfiguration.self,
            forPrimaryKey: displayable.configurationID
        )!
    }

    @MainActor
    func buttonConfiguration(displayableModelObjectID: String) -> ButtonConfiguration {
        let displayable = databaseManager.database().object(
            ofType: DisplayableModelObject.self,
            forPrimaryKey: displayableModelObjectID
        )!
        return databaseManager.database().object(
            ofType: ButtonConfiguration.self,
            forPrimaryKey: displayable.configurationID
        )!
    }

}
