import ApplicationConfiguration
import SwiftUI
import RealmSwift
import Factory
import Combine

enum ButtonMode {
    case toggle
    case turnOn
    case turnOff
}

class HAButtonViewModel: ObservableObject {
    enum Alignment {
        case hotizontal
        case vertical
    }
    @Injected(\.iconMapper) private var iconMapper
    @Injected(\.databaseManager) private var databaseManager
    var tokens: [NotificationToken] = []

    @Published var iconName: String = ""
    @Published var color: Color = .white
    @Published var title: String = ""

    init(entityID: String) {
        if let token = databaseManager
            .listenForEntityChange(
                id: entityID,
                callback: { [weak self] entity in
                    self?.updateModel(from: entity)
                }
            ) {
            tokens.append(token)
        }
    }

    func updateModel(from entity: Entity) {
        iconName = iconMapper.map(entity: entity)
        color = IconColorTransformer.transform(entity)
        title = entity.displayName()
    }
}

struct HAButton: View {
    @ObservedObject var viewModel: HAButtonViewModel

    init(entityID: String) {
        viewModel = .init(entityID: entityID)
    }

    var body: some View {
        HStack {
            content
        }
    }

    var content: some View {
        HStack {
            HAWidgetImageView(imageName: viewModel.iconName,
                              color: viewModel.color)
            HAMainTextView(text: viewModel.title)
        }
    }
}
