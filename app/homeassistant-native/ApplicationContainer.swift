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
}
