import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

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
    @Injected(\.homeAssistant) private var homeAssistant

    @Published var iconName: String = ""
    @Published var color: Color = .white
    @Published var title: String = ""
    @Published var alignment: Alignment = .vertical
    @Published var isWaitingForResponse = false

    var tokens: [NotificationToken] = []
    var entityID: String
    var buttonMode: ButtonMode = .toggle

    private var state: Bool = true

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
        color = IconColorTransformer.transform(entity)
        title = entity.displayName()
        state = entity.state == "on" ? true : false
        isWaitingForResponse = false
    }

    @MainActor
    func handleTap() async {
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

struct HAButton: View {
    @ObservedObject var viewModel: HAButtonViewModel

    init(entityID: String) {
        viewModel = .init(entityID: entityID)
    }

    var body: some View {
        if viewModel.alignment == .hotizontal {
            HStack {
                content
            }
        } else {
            VStack {
                content
            }
        }
    }

    var content: some View {
        Group {
            if viewModel.isWaitingForResponse {
                ProgressView()
                    .frame(width: 42, height: 42)
                    .padding(.trailing)
            } else {
                HAWidgetImageView(
                    imageName: viewModel.iconName,
                    color: viewModel.color
                )
            }
            Text(viewModel.title)
                .fontWeight(.medium)
                .foregroundColor(ColorManager.haDefaultDark)
                .frame(
                    maxWidth: .infinity,
                    alignment: viewModel.alignment == .hotizontal ? .leading : .center
                )
        }
        .onTapGesture {
            Task {
                await viewModel.handleTap()
            }
        }

    }
}
