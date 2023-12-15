//
//  HATarget.swift
//  homeassistant-native
//
//  Created by Charles Vu on 15/12/2023.
//

import Foundation

struct HATarget: Codable {
    let entityID: String

    enum CodingKeys: String, CodingKey {
        case entityID = "entity_id"
    }
}
