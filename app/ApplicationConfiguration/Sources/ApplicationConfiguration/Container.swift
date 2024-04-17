import Factory

extension Container {
    public var config: Factory<ApplicationConfiguration> {
        Factory(self) { ApplicationConfiguration() }
            .singleton
    }

    public var homeAssistantConfigurationManager: Factory<HomeAssistantConfigurationManager> {
        Factory(self) { HomeAssistantConfigurationManager() }
            .singleton
    }

    public var databaseProvider: Factory<RealmProviding> {
        Factory(self) { PersistantRealmProvider() }.singleton
    }
}
