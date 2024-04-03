import Foundation
import ApplicationConfiguration

struct IconMapper {
    func map(entity: Entity) -> String {
        let haIcon = entity.icon
        let state = entity.state
        if haIcon == nil, let deviceClass = entity.id.split(separator: ".").first {
            return defaultIcon(deviceClass: String(deviceClass))
        }
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

    func defaultIcon(deviceClass: String) -> String{
        switch deviceClass {
        case "light":
            return "lightbulb.circle"
        default:
            print(deviceClass)
            return "questionmark"
        }
    }

}
