import Foundation

public struct EntityState: Codable, Hashable, Identifiable {
    public let entityId: String
    public let lastChanged: Date
    public let state: String
    public let attributes: EntityAttribute

    enum CodingKeys: String, CodingKey {
        case lastChanged = "last_changed"
        case entityId = "entity_id"
        case state
        case attributes
    }

    public static var zero = EntityState(
        entityId: "",
        lastChanged: .init(),
        state: "",
        attributes: .zero
    )

    // MARK: Identifiable
    public var id: String {
        return entityId
    }

    // MARK: Equatable
    public static func == (lhs: EntityState, rhs: EntityState) -> Bool {
        lhs.entityId == rhs.entityId
    }

    // MARK: Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(entityId)
    }
}

public struct EntityAttribute: Codable {
    public let unit: String?
    public let name: String?
    public let deviceClass: String?
    public let stateClass: String?
    public let temperature: Double?
    public let humidity: Int?
    public let windSpeed: Double!
    public let icon: String?
    public let rgb: [Double]?
    public let hs: [Double]?
    public let brightness: Double?
    public let hueType: String?

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
        case hueType = "hue_type"
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
        brightness: nil,
        hueType: nil
    )
}
