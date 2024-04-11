import SwiftUI

struct HAEntityView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: HAEntityViewModel

    init(displayableModelObjectID: String) {
        viewModel = .init(displayableModelObjectID: displayableModelObjectID)
    }

    var body: some View {
        HStack {
            HAWidgetImageView(
                imageName: viewModel.iconName,
                color: themeManager.current.text
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
            AnyView(HAFootNoteView(text: viewModel.title, alignement: .leading))
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
