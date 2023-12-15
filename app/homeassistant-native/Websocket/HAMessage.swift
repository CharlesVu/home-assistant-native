//
//  Message.swift
//  homeassistant-native
//
//  Created by Charles Vu on 13/12/2023.
//

import Foundation

struct HAMessage: Codable {
    var id: Int?
    var type: MessageType
    var haVersion: String?
    var accessToken: String?
    var success: Bool?
    var event: HAEvent?
    var result: [EntityState]?
    var domain: String?
    var service: String?
    var target: HATarget?

    enum MessageType: String, Codable {
        case authRequired = "auth_required"
        case auth
        case authOk = "auth_ok"
        case authInvalid = "auth_invalid"
        case subscribeEvents = "subscribe_events"
        case result
        case event
        case getStates = "get_states"
        case callService = "call_service"
        // Ignored
        case recorder_5min_statistics_generated
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case haVersion = "ha_version"
        case accessToken = "access_token"
        case success
        case event
        case result
        case domain
        case target
    }
}

