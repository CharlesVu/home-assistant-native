import SwiftUI

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
                    .tint(viewModel.color)
            } else {
                HAWidgetImageView(
                    imageName: viewModel.iconName,
                    color: viewModel.color
                )
            }
            HADetailTextView(
                text: viewModel.title,
                textAlignment: viewModel.alignment == .hotizontal ? .leading : .center
            )
        }
        .onTapGesture {
            Task {
                await viewModel.handleTap()
            }
        }

    }
}
