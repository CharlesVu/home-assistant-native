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

    public var databaseManager: Factory<RealmProvider> {
        Factory(self) { RealmManager() }.singleton
    }
}
