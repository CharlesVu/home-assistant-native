import Foundation
import HomeAssistant

struct StateTransformer {
    static func transform(_ entity: EntityState) -> String {
        if entity.attributes.deviceClass == "door" {
            if entity.state == "off" {
                return "Closed"
            } else {
                return "Open"
            }
        } else if let unit = entity.attributes.unit {
            return "\(entity.state)\(unit)"
        } else if entity.attributes.deviceClass == "battery_charging" {
            if entity.state == "off" {
                return "Not Charging"
            } else {
                return "Charging"
            }
        }

        return entity.state.capitalized
    }
}
