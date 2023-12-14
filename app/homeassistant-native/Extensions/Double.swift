//
//  Double.swift
//  homeassistant-native
//
//  Created by Charles Vu on 14/12/2023.
//

import Foundation

extension Double {
    func truncate(places : Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
    }
}
