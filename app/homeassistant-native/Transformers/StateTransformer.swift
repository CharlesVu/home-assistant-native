import ApplicationConfiguration
import Foundation
import HomeAssistant

struct StateTransformer {
    func displayableState(`for` entity: Entity) -> String {
        // remove the unknown/unavailable state from the computation so we don't append the unit
        if entity.state == "unknown" {
            return String(localized: "unknown")
        } else if entity.state == "unavailable" {
            return String(localized: "unavailable")
        }

        if let deviceClass = entity.deviceClass,
            let formattedState = defaultState(deviceClass: deviceClass, entity: entity)
        {
            return formattedState
        }
        if let unit = entity.unit {
            return "\(entity.state) \(unit)"
        }
        if let date = formattedDate(from: entity.state) {
            return date
        }
        let localizedKey = String.LocalizationValue(stringLiteral: entity.state)
        return String(localized: localizedKey)
    }

    func defaultState(deviceClass: DeviceClass, entity: Entity) -> String? {
        let unit = (entity.unit != nil ? "\(entity.unit!)" : "")
        let state = entity.state

        switch deviceClass {
            case .monetary:
                if let currency = Locale.current.currency?.identifier,
                    let stateValue = Double(state)
                {
                    if currency == unit {
                        let formattedCurrency = stateValue.formatted(.currency(code: currency))
                        return "\(formattedCurrency)"
                    } else {
                        return "\(stateValue.truncate(places: 2)) \(unit)"
                    }
                }
            default:
                return nil
        }
        return nil
    }

    func formattedDate(from state: String) -> String? {
        let dateFormatters = [DateFormatter.octopusTime, DateFormatter.hassTime]

        for dateFormatter in dateFormatters {
            if let date = dateFormatter.date(from: state) {
                return DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .short)
            }
        }

        return nil
    }
}
