import Factory

extension Container {
    var iconMapper: Factory<IconMapper> {
        Factory(self) { IconMapper() }
            .singleton
    }
}
