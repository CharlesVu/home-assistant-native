//
//  Message.swift
//  homeassistant-native
//
//  Created by Charles Vu on 13/12/2023.
//

import Foundation

struct HAMessage: Codable {
    enum MessageType: String, Codable {
        case authRequired = "auth_required"
        case auth
        case authOk = "auth_ok"
        case authInvalid = "auth_invalid"
        case subscribeEvents = "subscribe_events"
        case result
        case event
        case getStates = "get_states"
        // Ignored
        case recorder_5min_statistics_generated
    }

    var id: Int?
    var type: MessageType
    var haVersion: String?
    var accessToken: String?
    var success: Bool?
    var event: HAEvent?
    var result: [EntityState]?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case haVersion = "ha_version"
        case accessToken = "access_token"
        case success
        case event
        case result
    }
}

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
