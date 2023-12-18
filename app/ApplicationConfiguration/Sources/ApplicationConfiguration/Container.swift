import Factory

public extension Container {
    var config: Factory<ApplicationConfiguration> {
        Factory(self) { ApplicationConfiguration() }
            .singleton
    }

    var homeAssistantConfigurationManager: Factory<HomeAssistantConfigurationManager> {
        Factory(self) { HomeAssistantConfigurationManager() }
            .singleton
    }

    var sectionManager: Factory<SectionManager> {
        Factory(self) { SectionManager() }
            .singleton
    }

    var entityConfigurationManager: Factory<EntityConfigurationManager> {
        Factory(self) { EntityConfigurationManager() }
            .singleton
    }

}

extension Container {
    var databaseManager: Factory<RealmManager> {
        Factory(self) { RealmManager() }
            .singleton
    }
}
