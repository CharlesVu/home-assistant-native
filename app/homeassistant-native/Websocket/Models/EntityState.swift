import Foundation

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
    let rgb: [Double]?
    let hs: [Double]?
    let brightness: Double?

    enum CodingKeys: String, CodingKey {
        case unit = "unit_of_measurement"
        case name = "friendly_name"
        case deviceClass = "device_class"
        case stateClass = "state_class"
        case temperature
        case humidity
        case windSpeed = "wind_speed"
        case icon
        case rgb = "rgb_color"
        case hs = "hs_color"
        case brightness
    }

    static var zero = EntityAttribute(
        unit: nil,
        name: nil,
        deviceClass: nil,
        stateClass: nil,
        temperature: nil,
        humidity: nil,
        windSpeed: nil,
        icon: nil,
        rgb: nil,
        hs: nil,
        brightness: nil
    )
}
