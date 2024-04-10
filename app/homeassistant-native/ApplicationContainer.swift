import Factory

extension Container {
    var iconMapper: Factory<IconMapper> {
        Factory(self) { IconMapper() }
            .singleton
    }
    var stateFormatter: Factory<StateTransformer> {
        Factory(self) { StateTransformer() }
            .singleton
    }

    var entityStore: Factory<EntityStoring> {
        Factory(self) { EntityStore() }
    }

    var octopusStore: Factory<OctopusAgileStoring> {
        Factory(self) { OctopusAgileStore() }
    }

    var displayableStore: Factory<DisplayableStoring> {
        Factory(self) { DisplayableStore() }
    }
}
