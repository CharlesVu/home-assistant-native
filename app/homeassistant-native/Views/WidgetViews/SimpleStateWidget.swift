//
//  SimpleStateWidget.swift
//  homeassistant-native
//
//  Created by Charles Vu on 14/12/2023.
//

import SwiftUI
import Combine

class SimpleStateWidgetViewModel: ObservableObject {
    @Published var icon: String = ""
    @Published var name: String?
    @Published var type: String? = ""
    @Published var state: String = ""
    @Published var iconColor: Color = ColorManager.haDefaultDark

    private var subscriptions = Set<AnyCancellable>()

    init(
        initialState: EntityState,
        subject: PassthroughSubject<EntityState, Never>
    ) {
        updateViewModel(entity: initialState)

        subject
            .filter { $0.entityId == initialState.entityId}
            .receive(on: DispatchQueue.main)
            .sink {
                self.updateViewModel(entity: $0)
            }
            .store(in: &subscriptions)
    }

    func updateViewModel(entity: EntityState) {
        name = entity.attributes.name
        state = transformState(entity)
        if let icon = entity.attributes.icon {
            self.icon = IconMapper.map(haIcon: icon, state: entity.state)
        }
        iconColor = computeIconColor(entity)
    }

    func transformState(_ entity: EntityState) -> String {
        if entity.attributes.deviceClass == "door" {
            if entity.state == "off" {
                return "Closed"
            } else {
                return "Open"
            }
        } else if let unit = entity.attributes.unit {
            return "\(entity.state)\(unit)"
        } else if entity.attributes.deviceClass == "battery_charging" {
            if entity.state == "off" {
                return "Not Charging"
            } else {
                return "Charging"
            }
        }

        return entity.state.capitalized
    }

    func computeIconColor(_ entity: EntityState) -> Color {
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

struct SimpleStateWidget: View {
    @ObservedObject var viewModel: SimpleStateWidgetViewModel

    var body: some View {
        HStack {
            HAWidgetImageView(
                imageName: viewModel.icon,
                color: viewModel.iconColor
            )
            VStack(alignment: .leading) {
                HAMainTextView(text: viewModel.name ?? "nil")
            }
            HADetailTextView(text: viewModel.state)
        }
    }
}
