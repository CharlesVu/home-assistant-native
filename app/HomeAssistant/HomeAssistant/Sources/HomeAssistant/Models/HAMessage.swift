import Foundation

public struct HAMessage: Codable {
    public var id: Int?
    public var type: MessageType
    public var haVersion: String?
    public var accessToken: String?
    public var success: Bool?
    public var event: HAEvent?
    public var result: ResultType?
    public var domain: String?
    public var service: String?
    public var target: HATarget?

    public enum ResultType: Codable {
        case entities([EntityState])
        case single(HACallResult)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let values = try? container.decode([EntityState].self) {
                self = .entities(values)
                return
            }

            if let value = try? container.decode(HACallResult.self) {
                self = .single(value)
                return
            }

            throw DecodingError.typeMismatch(
                ResultType.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Type is not matched",
                    underlyingError: nil
                )
            )
        }
    }

    public enum MessageType: String, Codable {
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
        case service
    }
}
