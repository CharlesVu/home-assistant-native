import Foundation

public struct OctopusRate: Codable {
    public let start: Date
    public let end: Date
    public let value: Double

    enum CodingKeys: String, CodingKey {
        case start
        case end
        case value = "value_inc_vat"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.start = try container.decode(Date.self, forKey: .start)
        self.end = try container.decode(Date.self, forKey: .end)
        self.value = try container.decode(Double.self, forKey: .value)
    }
}
