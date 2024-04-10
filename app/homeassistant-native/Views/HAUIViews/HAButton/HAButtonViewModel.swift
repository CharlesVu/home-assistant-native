import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class HAButtonViewModel: ObservableObject {
    @Injected(\.iconMapper) private var iconMapper
    @Injected(\.displayableStore) private var displayableStore
    @Injected(\.entityStore) private var entityStore
    @Injected(\.homeAssistant) private var homeAssistant

    @Published var iconName: String = "circle"
    @Published var color: Color = .white
    @Published var title: String = ""
    @Published var alignment: ButtonAlignment = .vertical
    @Published var isWaitingForResponse = false

    private var entityObserverToken: NotificationToken?
    private var configurationObserverToken: NotificationToken?
    private var entityID: String!
    private var buttonMode: ButtonMode = .toggle
    private var configuration: ButtonConfiguration!

    private var state: Bool?

    init(displayableModelObjectID: String) {
        configuration = displayableStore.buttonConfiguration(displayableModelObjectID: displayableModelObjectID)
        Task {
            await observeConfiguration()
            await observeEntity()
        }
    }

    @MainActor
    func observeConfiguration() {
        applyConfiguration()

        configurationObserverToken = configuration.observe { [weak self] _ in
            self?.observeEntity()
            self?.applyConfiguration()
        }
    }

    @MainActor
    func applyConfiguration() {
        alignment = configuration.alignment
        buttonMode = configuration.mode
    }

    @MainActor
    func observeEntity() {
        if let entityID = configuration.entityID {
            self.entityID = entityID
            entityObserverToken =
                entityStore
                .listenForEntityChange(
                    id: entityID,
                    callback: { [weak self] entity in
                        self?.updateModel(from: entity)
                    }
                )
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
