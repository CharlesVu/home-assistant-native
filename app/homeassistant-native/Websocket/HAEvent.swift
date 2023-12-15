//
//  HAEvent.swift
//  homeassistant-native
//
//  Created by Charles Vu on 13/12/2023.
//

import Foundation

struct HAEvent: Codable {
    let eventType: EventType
    let data: EventData

    enum EventType: String, Codable {
        case stateChanged = "state_changed"
        case serviceRemoved = "service_removed"
        case serviceRegistered = "service_registered"
        case callService = "call_service"
        case click
    }

    enum CodingKeys: String, CodingKey {
        case eventType = "event_type"
        case data
    }
}

struct EventData: Codable {
    let entityId: String
    let oldState: EntityState
    let newState: EntityState

    enum CodingKeys: String, CodingKey {
        case entityId = "entity_id"
        case oldState = "old_state"
        case newState = "new_state"
    }
}

struct EntityState: Codable, Hashable, Identifiable {
    let entityId: String
    let lastChanged: Date
    let state: String
    let attributes: EntityAttribute

    enum CodingKeys: String, CodingKey {
        case lastChanged = "last_changed"
        case entityId = "entity_id"
        case state
        case attributes
    }

    static var zero = EntityState(entityId: "", lastChanged: .init(), state: "", attributes: .zero)

    // MARK: Identifiable
    var id: String {
        return entityId
    }

    // MARK: Equatable
    static func == (lhs: EntityState, rhs: EntityState) -> Bool {
        lhs.entityId == rhs.entityId
    }

    // MARK: Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(entityId)
    }
}

struct EntityAttribute: Codable {
    let unit: String?
    let name: String?
    let deviceClass: String?
    let stateClass: String?
    let temperature: Double?
    let humidity: Int?
    let windSpeed: Double!
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case unit = "unit_of_measurement"
        case name = "friendly_name"
        case deviceClass = "device_class"
        case stateClass = "state_class"
        case temperature
        case humidity
        case windSpeed = "wind_speed"
        case icon
    }
    
    static var zero = EntityAttribute(unit: nil, name: nil, deviceClass: nil, stateClass: nil, temperature: nil, humidity: nil, windSpeed: nil, icon: nil)
}
