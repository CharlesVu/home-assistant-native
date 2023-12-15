import Factory

extension Container {
    var websocket: Factory<HomeAssistantBridging> {
        Factory(self) { HomeAssistantBridge() }
            .singleton
    }

    var config: Factory<Config> {
        Factory(self) { Config() }
            .singleton
    }
}
