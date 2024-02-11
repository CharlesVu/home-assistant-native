import ApplicationConfiguration
import SwiftUI

struct IconColorTransformer {
    static func transform(_ entity: EntityModelObject) -> Color {
        if entity.attributes?.deviceClass == "battery" {
            if let stateValue = Int(entity.state) {
                if stateValue < 25 {
                    return ColorManager.error
                } else if stateValue < 50 {
                    return ColorManager.warning
                } else if stateValue < 75 {
                    return ColorManager.neutral
                } else {
                    return ColorManager.positive
                }
            }
        } else if entity.attributes?.deviceClass == "door" {
            if entity.state == "off" {
                return ColorManager.neutral
            } else {
                return ColorManager.warning
            }
        } else if entity.entityID.hasPrefix("lock") {
            if entity.state == "locked" {
                return ColorManager.neutral
            } else {
                return ColorManager.warning
            }
        } else if
            let brightness = entity.attributes?.brightness,
            entity.attributes?.hs.count == 2
        {
            let hs = entity.attributes!.hs
            return Color(hue: hs[0] / 255, saturation: hs[1] / 255, brightness: brightness / 255)
        }

        return ColorManager.haDefaultDark
    }

}
