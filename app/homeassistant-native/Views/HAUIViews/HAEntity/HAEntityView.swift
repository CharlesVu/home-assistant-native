import SwiftUI

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
            if viewModel.alignment == .vertical {
                VStack {
                    content
                }
            } else {
                HStack {
                    content
                }
            }
        }
    }

    var content: some View {
        Group {
            title
            detail
        }
    }

    var title: some View {
        if viewModel.alignment == .vertical {
            AnyView(HAFootNoteView(text: viewModel.title))
        } else {
            AnyView(HAMainTextView(text: viewModel.title))
        }
    }

    var detail: some View {
        HADetailTextView(
            text: viewModel.state,
            textAlignment: viewModel.alignment == .vertical ? .leading : .trailing
        )
    }
}
