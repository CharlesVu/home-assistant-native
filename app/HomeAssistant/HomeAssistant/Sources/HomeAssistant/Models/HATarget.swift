import Foundation

public struct HATarget: Codable {
    public let entityID: String

    enum CodingKeys: String, CodingKey {
        case entityID = "entity_id"
    }
}
