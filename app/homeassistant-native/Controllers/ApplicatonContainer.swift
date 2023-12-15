//
//  ApplicatonContainer.swift
//  homeassistant-native
//
//  Created by Charles Vu on 15/12/2023.
//

import Factory

extension Container {
    var websocket: Factory<HomeAssistantBridging> {
        Factory(self) { HomeAssistantBridge() }
            .singleton
    }
}
