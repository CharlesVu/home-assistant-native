import Factory

public extension Container {
    var homeAssistant: Factory<HomeAssistantBridging> {
        Factory(self) { HomeAssistantBridge() }
            .singleton
    }
}
