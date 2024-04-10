import ApplicationConfiguration
import Factory
import RealmSwift
import SwiftUI

class HAVStackViewModel: ObservableObject {
    @Injected(\.displayableStore) var displayableStore
    var configuration: VStackConfiguration!
    var tokens: [NotificationToken] = []
    @Published var subViews = [HAViewType]()

    init(displayableModelObjectID: String) {
        configuration = displayableStore.vStackConfiguration(displayableModelObjectID: displayableModelObjectID)
        Task {
            await mapSubViews()
        }
    }

    @MainActor
    func mapSubViews() async {
        subViews = []
        for element in configuration.children {
            if let destination = HAViewBuilder().map(model: element) {
                subViews.append(destination)
            }
        }
    }

}

struct HAVStack: View {
    @ObservedObject var viewModel: HAVStackViewModel

    init(displayableModelObjectID: String) {
        viewModel = .init(displayableModelObjectID: displayableModelObjectID)
    }

    var body: some View {
        VStack {
            List {
                children
            }
        }
    }

    var children: some View {
        ForEach(viewModel.subViews) { subview in
            HAViewBuilder().view(viewType: subview)
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    return 8
                }
                .alignmentGuide(.listRowSeparatorTrailing) { viewDimensions in
                    return viewDimensions[.listRowSeparatorTrailing] - 8
                }

        }
    }
}
