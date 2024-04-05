import ApplicationConfiguration
import Foundation
import OSLog

struct IconMapper {
    let messageLogger = Logger(subsystem: "IconMapper", category: "Icon")

    func map(entity: Entity) -> String {
        let haIcon = entity.icon
        let state = entity.state
        let deviceClass = entity.deviceClass

        switch haIcon {
            case "mdi:lightning-bolt":
                return "bolt.fill"
            case "mdi:car-battery":
                return batteryIcon(currentState: state)
            case "mdi:ev-station":
                return "car.top.radiowaves.rear.right"
            case "mdi:lock":
                if state == "locked" || state == "on" {
                    return "lock"
                } else {
                    return "lock.open"
                }
            case "mdi:lightbulb-group":
                return "lightbulb.led.wide.fill"
            case "mdi:home":
                return "house"
            case "mdi:play":
                return "play"
            default:
                ()
        }
        if let deviceClass = deviceClass {
            return defaultIcon(deviceClass: deviceClass, state: state)
        } else if let derivedDeviceClass = entity.id.components(separatedBy: ".").first {
            return defaultIcon(derivedClass: derivedDeviceClass, state: state)
        }

        return "questionmark"
    }

    func defaultIcon(derivedClass: String, state: String) -> String {
        switch derivedClass {
            case "light":
                if state == "on" {
                    return "lightbulb.max.fill"
                } else if state == "off" {
                    return "lightbulb.slash"
                } else {
                    return "wifi.exclamationmark"
                }
            case "person":
                return "person.fill"
            case "sun":
                return "sun.max"
            case "automation":
                return "bolt.badge.automatic.fill"
            case "weather":
                return "cloud"
            case "button":
                return "questionmark.circle.fill"
            case "sensor":
                return "eye"
            case "scene":
                return "swatchpalette"
            case "event":
                return "cursorarrow.click.badge.clock"
            case "select":
                return "filemenu.and.selection"
            case "switch", "binary_sensor":
                if state == "on" {
                    return "lightswitch.on"
                } else {
                    return "lightswitch.off"
                }
            case "time":
                return "calendar"
            case "vacuum":
                return "figure.wave"
            default:
                messageLogger.warning("No default icon found for derived class: \(derivedClass)")
                return "questionmark"
        }
    }

    func defaultIcon(deviceClass: DeviceClass, state: String) -> String {
        switch deviceClass {
            case .humidity:
                return "humidity.fill"
            case .battery:
                return batteryIcon(currentState: state)
            case .timestamp:
                return "clock.fill"
            case .monetary:
                return "dollarsign.circle.fill"
            case .power:
                return "bolt.fill"
            case .current:
                return "alternatingcurrent"
            case .energy:
                return "bolt.fill"
            case .gas:
                return "flame"
            case .connectivity:
                return "wifi"
            case .duration:
                return "clock.fill"
            case .temperature:
                return "thermometer.low"
            case .atmosphericPressure:
                return "thermometer.and.liquid.waves"
            case .button:
                return "lightswitch.on"
            case .door:
                if state == "on" {
                    return "door.left.hand.closed"
                } else {
                    return "door.left.hand.open"
                }
            default:
                messageLogger.warning("No default icon found for device class: \(deviceClass.rawValue)")
                return "questionmark"
        }
    }

    func batteryIcon(currentState: String) -> String {
        if let stateValue = Int(currentState) {
            if stateValue == 0 {
                return "battery.0percent"
            } else if stateValue < 25 {
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
    }
}
