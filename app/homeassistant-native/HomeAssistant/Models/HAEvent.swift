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
