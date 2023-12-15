import Factory

extension Container {
    var websocket: Factory<HomeAssistantBridging> {
        Factory(self) { HomeAssistantBridge() }
            .singleton
    }
}
