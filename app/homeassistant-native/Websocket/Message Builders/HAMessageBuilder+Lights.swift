import Foundation

extension HAMessageBuilder {
    static func turnLight(on: Bool, entityID: String) -> HAMessage {
        let serviceName = on ? "turn_on" : "turn_off"
        return HAMessage(
            type: .callService,
            domain: "light",
            service: serviceName,
            target: .init(entityID: entityID)
        )
    }
}
