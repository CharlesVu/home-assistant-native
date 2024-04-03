import Factory

extension Container {
    public var homeAssistant: Factory<HomeAssistantBridging> {
        Factory(self) { HomeAssistantBridge() }
            .singleton
    }
}
