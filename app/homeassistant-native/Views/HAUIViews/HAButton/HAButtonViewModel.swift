import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class HAButtonViewModel: ObservableObject {
    enum Alignment {
        case hotizontal
        case vertical
    }

    enum ButtonMode {
        case toggle
        case turnOn
        case turnOff
    }

    @Injected(\.iconMapper) private var iconMapper
    @Injected(\.displayableStore) private var displayableStore
    @Injected(\.entityStore) private var entityStore
    @Injected(\.homeAssistant) private var homeAssistant

    @Published var iconName: String = "circle"
    @Published var color: Color = .white
    @Published var title: String = ""
    @Published var alignment: Alignment = .vertical
    @Published var isWaitingForResponse = false

    var tokens: [NotificationToken] = []
    var entityID: String!
    var buttonMode: ButtonMode = .toggle
    var configuration: ButtonConfiguration!

    private var state: Bool?

    init(displayableModelObjectID: String) {
        configuration = displayableStore.buttonConfiguration(displayableModelObjectID: displayableModelObjectID)
        if let entityID = configuration.entityID {
            self.entityID = entityID
            if let token =
                entityStore
                .listenForEntityChange(
                    id: entityID,
                    callback: { entity in
                        Task { [weak self] in
                            await self?.updateModel(from: entity)
                        }
                    }
                )
            {
                tokens.append(token)
            }
        }
    }

    @MainActor
    func updateModel(from entity: Entity) {
        iconName = iconMapper.map(entity: entity)
        color = ColorManager.haDefaultDark
        title = entity.displayName()
        if entity.state == "on" {
            state = true
        } else if entity.state == "unavailable" {
            state = nil
        } else {
            state = false
        }

        isWaitingForResponse = false
    }

    @MainActor
    func handleTap() async {
        guard let state else { return }
        let desiredState: Bool

        switch buttonMode {
            case .toggle:
                desiredState = !state
            case .turnOff:
                desiredState = false
            case .turnOn:
                desiredState = true
        }

        if !isWaitingForResponse {
            isWaitingForResponse = true

            _ = try! await homeAssistant.turnLight(
                on: desiredState,
                entityID: entityID
            )
        }

    }
}