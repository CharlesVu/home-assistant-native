//
//  SimpleStateWidget.swift
//  homeassistant-native
//
//  Created by Charles Vu on 14/12/2023.
//

import SwiftUI
import Combine
import Factory

class SimpleStateWidgetViewModel: ObservableObject {
    @Injected(\.websocket) private var websocket

    @Published var icon: String = ""
    @Published var name: String?
    @Published var type: String? = ""
    @Published var state: String = ""
    @Published var iconColor: Color = ColorManager.haDefaultDark

    private var subscriptions = Set<AnyCancellable>()

    init(
        initialState: EntityState
    ) {
        updateViewModel(entity: initialState)

        websocket.subject
            .filter { $0.entityId == initialState.entityId}
            .receive(on: DispatchQueue.main)
            .sink {
                self.updateViewModel(entity: $0)
            }
            .store(in: &subscriptions)
    }

    func updateViewModel(entity: EntityState) {
        name = entity.attributes.name
        state = StateTransformer.transform(entity)
        if let icon = entity.attributes.icon {
            self.icon = IconMapper.map(haIcon: icon, state: entity.state)
        }
        iconColor = IconColorTransformer.transform(entity)
    }
}

struct SimpleStateWidget: View {
    @ObservedObject var viewModel: SimpleStateWidgetViewModel

    init(initialState: EntityState) {
        viewModel = .init(initialState: initialState)
    }
    
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
