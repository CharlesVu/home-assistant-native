//
//  IconColorTransformer.swift
//  homeassistant-native
//
//  Created by Charles Vu on 15/12/2023.
//

import SwiftUI

struct IconColorTransformer {
    static func transform(_ entity: EntityState) -> Color {
        if entity.attributes.deviceClass == "battery" {
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
        } else if entity.attributes.deviceClass == "door" {
            if entity.state == "off" {
                return ColorManager.neutral
            } else {
                return ColorManager.warning
            }
        } else if entity.entityId.hasPrefix("lock") {
            if entity.state == "locked" {
                return ColorManager.neutral
            } else {
                return ColorManager.warning
            }
        }

        return ColorManager.haDefaultDark
    }

}
