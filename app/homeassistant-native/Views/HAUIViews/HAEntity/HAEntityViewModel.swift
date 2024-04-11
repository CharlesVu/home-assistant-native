import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class HAEntityViewModel: ObservableObject {
    @Injected(\.displayableStore) private var displayableStore
    @Injected(\.iconMapper) private var iconMapper
    @Injected(\.stateFormatter) private var stateFormatter
    @Injected(\.entityStore) private var entityStore

    @Published var iconName: String = "circle"
    @Published var color: Color = .white
    @Published var title: String = ""
    @Published var state: String = ""
    @Published var alignment: StateDisplayAlignment = .vertical

    private var entityObserverToken: NotificationToken?
    private var configurationObserverToken: NotificationToken?
    private var configuration: StateDisplayConfiguration?

    init(displayableModelObjectID: String) {
        configuration = displayableStore.stateDisplayConfiguration(displayableModelObjectID: displayableModelObjectID)
        Task {
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
        color = ColorManager.haDefaultDark
        title = entity.displayName()
        state = stateFormatter.displayableState(for: entity)
    }
}
