import ApplicationConfiguration
import Factory
import SwiftUI

struct IconColorTransformer {
    @Injected(\.themeManager) var themeManager

    func transform(_ entity: Entity) -> Color {
        if entity.deviceClass == .battery {
            if let stateValue = Int(entity.state) {
                if stateValue < 25 {
                    return themeManager.current.red
                } else if stateValue < 50 {
                    return themeManager.current.orange
                } else if stateValue < 75 {
                    return themeManager.current.text
                } else {
                    return themeManager.current.green
                }
            }
        } else if entity.deviceClass == .door {
            if entity.state == "off" {
                return themeManager.current.text
            } else {
                return themeManager.current.orange
            }
        } else if entity.id.hasPrefix("lock") {
            if entity.state == "locked" {
                return themeManager.current.text
            } else {
                return themeManager.current.orange
            }
        } else if let brightness = entity.brightness,
            entity.hs.count == 2
        {
            let hs = entity.hs
            return Color(hue: hs[0] / 255, saturation: hs[1] / 255, brightness: brightness / 255)
        }

        return themeManager.current.text
    }

}
