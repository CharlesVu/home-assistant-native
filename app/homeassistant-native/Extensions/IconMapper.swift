//
//  IconMappter.swift
//  homeassistant-native
//
//  Created by Charles Vu on 14/12/2023.
//

import Foundation

struct IconMapper {
    static func map(haIcon: String, state: String?) -> String {
        switch haIcon {
        case "mdi:lightning-bolt":
            return "bolt.fill"
        case "mdi:car-battery":
            if let state, let stateValue = Int(state) {
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
        default:
            print("!!! \(haIcon)")
            return "questionmark.diamond.fill"
        }
    }
}
