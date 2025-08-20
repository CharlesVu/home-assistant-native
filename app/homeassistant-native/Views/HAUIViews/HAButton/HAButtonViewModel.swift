import ApplicationConfiguration
import Combine
import HomeAssistant
import RealmSwift
import SwiftUI

class HAButtonViewModel: ObservableObject {
    private var iconMapper: IconMapper!
    private var displayableStore: (any DisplayableStoring)!
    private var entityStore: (any EntityStoring)!
    private var homeAssistant: (any HomeAssistantBridging)!

    @Published var iconName: String = "circle"
    @Published var title: String = ""
    @Published var alignment: ButtonAlignment = .vertical
    @Published var isWaitingForResponse = false

    private var entityObserverToken: NotificationToken?
    var configurationObserverToken: NotificationToken?
    var entityID: String!
    var buttonMode: ButtonMode = .toggle
    var configuration: ButtonConfiguration?

    var state: Bool?
    private let displayableModelObjectID: String

    init(displayableModelObjectID: String) {
        self.displayableModelObjectID = displayableModelObjectID
    }

    func set(
        displayableStore: any DisplayableStoring,
        entityStore: any EntityStoring,
        homeAssistant: any HomeAssistantBridging,
        iconMapper: IconMapper
    ) {
        self.displayableStore = displayableStore
        self.entityStore = entityStore
        self.homeAssistant = homeAssistant
        self.iconMapper = iconMapper

        Task {
            configuration = await displayableStore.buttonConfiguration(
                displayableModelObjectID: displayableModelObjectID
            )
            await observeConfiguration()
            await observeEntity()
        }
    }

    @MainActor
    func observeConfiguration() {
        applyConfiguration()

        configurationObserverToken = displayableStore.observe(
            configuration,
            onChange: { [weak self] in
                self?.observeEntity()
                self?.applyConfiguration()
            },
            onDelete: { [weak self] in
                self?.configuration = nil
                self?.configurationObserverToken = nil
            }
        )
    }

    @MainActor
    func applyConfiguration() {
        guard let configuration else { return }
        alignment = configuration.alignment
        buttonMode = configuration.mode
    }

    @MainActor
    func observeEntity() {
        if let entityID = configuration?.entityID {
            self.entityID = entityID
            entityObserverToken =
                entityStore
                .listenForEntityChange(
                    id: entityID,
                    onChange: { [weak self] entity in
                        self?.updateModel(from: entity)
                    },
                    onDelete: { [weak self] in
                        self?.entityObserverToken = nil
                    }
                )
        }
    }

    @MainActor
    func updateModel(from entity: Entity) {
        iconName = iconMapper.map(entity: entity)
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
