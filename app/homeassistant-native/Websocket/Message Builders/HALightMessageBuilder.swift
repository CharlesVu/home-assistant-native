//
//  HALightMessageBuilder.swift
//  homeassistant-native
//
//  Created by Charles Vu on 15/12/2023.
//

import Foundation

struct HALightMessageBuilder {
    static func turnLight(on: Bool, entityID: String) -> HAMessage {
        let serviceName = on ? "turn_on" : "turn_off"
        return HAMessage(
            type: .callService,
            domain: "light", 
            service: serviceName,
            target: .init(entityID: entityID)
        )
    }
}
