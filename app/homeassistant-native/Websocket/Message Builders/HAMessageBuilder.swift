//
//  HAMessageBuilder.swift
//  homeassistant-native
//Hi
//  Created by Charles Vu on 15/12/2023.
//

import Foundation

struct HAMessageBuilder {
    static var _currentID = 0
    static var currentID: Int {
        _currentID += 1
        return _currentID
    }

    static func authMessage(accessToken: String) -> HAMessage {
        HAMessage(type: .auth, accessToken: accessToken)
    }

    static func subscribeMessage() -> HAMessage {
        HAMessage(id: currentID, type: .subscribeEvents)
    }

    static func getStateMessage() -> HAMessage {
        HAMessage(id: currentID, type: .getStates)
    }
}
