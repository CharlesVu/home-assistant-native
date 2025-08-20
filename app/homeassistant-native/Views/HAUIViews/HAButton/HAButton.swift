import HomeAssistant
import SwiftUI

struct HAButton: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var iconMapper: IconMapper
    @EnvironmentObject private var displayableStore: DisplayableStore
    @EnvironmentObject private var entityStore: EntityStore
    @EnvironmentObject private var homeAssistant: HomeAssistantBridge

    @ObservedObject var viewModel: HAButtonViewModel

    init(displayableModelObjectID: String) {
        viewModel = .init(displayableModelObjectID: displayableModelObjectID)
    }

    var body: some View {
        if viewModel.alignment == .horizontal {
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
                    .tint(themeManager.current.text)
            } else {
                HAWidgetImageView(
                    imageName: viewModel.iconName,
                    color: themeManager.current.text
                )
            }
            HADetailTextView(
                text: viewModel.title,
                textAlignment: viewModel.alignment == .horizontal ? .leading : .center
            )
        }
        .onTapGesture {
            Task {
                await viewModel.handleTap()
            }
        }
        .onAppear {
            viewModel.set(
                displayableStore: displayableStore,
                entityStore: entityStore,
                homeAssistant: homeAssistant,
                iconMapper: iconMapper
            )
        }

    }
}
