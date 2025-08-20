import ApplicationConfiguration
import HomeAssistant

class Dependencies {
    let db = PersistantRealmProvider()
    let homeAssistantConfigurationManager = HomeAssistantConfigurationManager()
    lazy var homeAssistant = HomeAssistantBridge(homeAssistantConfigurationManager: homeAssistantConfigurationManager)
    lazy var octopusStore = OctopusAgileStore(databaseProvider: db)
    lazy var entityStore = EntityStore(databaseProvider: db)
    lazy var displayableStore = DisplayableStore(databaseProvider: db)
    let iconMapper = IconMapper()
    let stateTransformer = StateTransformer()
    lazy var iconColorTransformer = IconColorTransformer(themeManager: themeManager)
    let themeManager = ThemeManager()
}
