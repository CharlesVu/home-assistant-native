//
//  JSONDescription.swift
//  homeassistant-native
//
//  Created by Charles Vu on 13/12/2023.
//

import Foundation

extension Encodable {
    func jsonDescription() -> String {
        String(data: try! JSONEncoder().encode(self), encoding: .utf8) ?? ""
    }
}
