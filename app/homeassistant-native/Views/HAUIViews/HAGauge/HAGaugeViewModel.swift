import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class HAGaugeViewModel: ObservableObject {
    @Injected(\.entityStore) private var entityStore
    @Injected(\.stateFormatter) private var stateFormatter

    var entityID: String
    var token: NotificationToken?

    @Published var currentValue: Double = 0
    @Published var displayableValue: String = ""
    @Published var minValue: Double = 0
    @Published var maxValue: Double = 100
    @Published var title: String = ""

    init(entityID: String) {
        self.entityID = entityID
        token =
            entityStore
            .listenForEntityChange(
                id: entityID,
                onChange: { entity in
                    Task { [weak self] in
                        await self?.updateModel(from: entity)
                    }
                },
                onDelete: { [weak self] in
                    self?.token = nil
                }
            )
    }

    @MainActor
    func updateModel(from entity: Entity) {
        if let value = Double(entity.state) {
            currentValue = value
            displayableValue = stateFormatter.displayableState(for: entity)
            title = entity.displayName()
            if entity.unit == "%" {
                minValue = 0
                maxValue = 100
            }
        }
    }
}
