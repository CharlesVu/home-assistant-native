import Foundation

struct HATarget: Codable {
    let entityID: String

    enum CodingKeys: String, CodingKey {
        case entityID = "entity_id"
    }
}
