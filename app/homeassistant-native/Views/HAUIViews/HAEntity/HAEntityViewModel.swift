import ApplicationConfiguration
import Combine
import RealmSwift
import SwiftUI

class HAEntityViewModel: ObservableObject {
    private var iconMapper: IconMapper!
    private var displayableStore: (any DisplayableStoring)!
    private var entityStore: (any EntityStoring)!
    private var stateFormatter: StateTransformer!

    @Published var iconName: String = "circle"
    @Published var title: String = ""
    @Published var state: String = ""
    @Published var alignment: StateDisplayAlignment = .vertical

    private var entityObserverToken: NotificationToken?
    private var configurationObserverToken: NotificationToken?
    private var configuration: StateDisplayConfiguration?
    private let displayableModelObjectID: String

    init(displayableModelObjectID: String) {
        self.displayableModelObjectID = displayableModelObjectID
    }

    func set(
        displayableStore: any DisplayableStoring,
        entityStore: any EntityStoring,
        stateFormatter: StateTransformer,
        iconMapper: IconMapper
    ) {
        self.displayableStore = displayableStore
        self.entityStore = entityStore
        self.stateFormatter = stateFormatter
        self.iconMapper = iconMapper

        Task {
            configuration = await displayableStore.stateDisplayConfiguration(
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
    }

    @MainActor
    func observeEntity() {
        if let entityID = configuration?.entityID {
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
        state = stateFormatter.displayableState(for: entity)
    }
}
