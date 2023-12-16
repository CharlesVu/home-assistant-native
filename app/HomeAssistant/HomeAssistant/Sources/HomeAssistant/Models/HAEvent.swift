import Foundation

public struct HAEvent: Codable {
    public let eventType: EventType
    public let data: EventData

    public enum EventType: String, Codable {
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

public struct EventData: Codable {
    public let entityId: String
    public let oldState: EntityState
    public let newState: EntityState

    enum CodingKeys: String, CodingKey {
        case entityId = "entity_id"
        case oldState = "old_state"
        case newState = "new_state"
    }
}
