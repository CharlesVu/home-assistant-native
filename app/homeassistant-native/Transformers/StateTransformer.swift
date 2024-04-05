import ApplicationConfiguration
import Foundation
import HomeAssistant

struct StateTransformer {
    func displayableState(`for` entity: Entity) -> String {
        let state = entity.state
        let unit = (entity.unit != nil ? " \(entity.unit!)" : "")
        let deviceClass = entity.deviceClass

        switch deviceClass {
            case .humidity, .battery:
                return "\(entity.state )\(unit)"
            case .timestamp:
                return formattedDate(from: state)
            default:
                let localizedKey = String.LocalizationValue(stringLiteral: state)
                return String(localized: localizedKey)
        }
    }

    func formattedDate(from state: String) -> String {
        guard let date = DateFormatter.octopusTime.date(from: state) else {
            return state
        }
        return DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .short)
    }
}
