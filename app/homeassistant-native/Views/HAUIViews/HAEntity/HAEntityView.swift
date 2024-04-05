import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class HAEntityViewModel: ObservableObject {
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
    @Injected(\.stateFormatter) private var stateFormatter
    @Injected(\.databaseManager) private var databaseManager

    @Published var iconName: String = "circle"
    @Published var color: Color = .white
    @Published var title: String = ""
    @Published var state: String = ""
    @Published var alignment: Alignment = .vertical

    var tokens: [NotificationToken] = []
    var entityID: String
    var buttonMode: ButtonMode = .toggle

    init(entityID: String) {
        self.entityID = entityID
        if let token =
            databaseManager
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

    @MainActor
    func updateModel(from entity: Entity) {
        iconName = iconMapper.map(entity: entity)
        color = ColorManager.haDefaultDark
        title = entity.displayName()
        state = stateFormatter.displayableState(for: entity)
    }
}

struct HAEntityView: View {
    @ObservedObject var viewModel: HAEntityViewModel

    init(entityID: String) {
        viewModel = .init(entityID: entityID)
    }

    var body: some View {
        HStack {
            HAWidgetImageView(
                imageName: viewModel.iconName,
                color: viewModel.color
            )
            HAMainTextView(text: viewModel.title)
            HADetailTextView(text: viewModel.state)
        }
    }
}
