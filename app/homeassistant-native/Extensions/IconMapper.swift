import Foundation
import ApplicationConfiguration

struct IconMapper {
    static func map(entity: EntityModelObject) -> String {
        let haIcon = entity.attributes.icon
        let state = entity.state
        switch haIcon {
            case "mdi:lightning-bolt":
                return "bolt.fill"
            case "mdi:car-battery":
                if let stateValue = Int(state) {
                    if stateValue < 25 {
                        return "battery.25percent"
                    } else if stateValue < 50 {
                        return "battery.50percent"
                    } else if stateValue < 75 {
                        return "battery.75percent"
                    } else {
                        return "battery.100percent"
                    }
                }
                return "battery.100percent.bolt"
            case "mdi:ev-station":
                return "car.top.radiowaves.rear.right"
            case "mdi:lock":
                if state == "locked" {
                    return "car.side.lock"
                } else {
                    return "car.side.lock.open"
                }
            case "mdi:lightbulb-group":
                return "lightbulb.led.wide.fill"
            default:
                return "questionmark.diamond.fill"
        }
    }
}
