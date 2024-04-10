import ApplicationConfiguration
import Factory
import RealmSwift
import SwiftUI

class HAVStackViewModel: ObservableObject {
    @Injected(\.displayableStore) var displayableStore
    var configuration: VStackConfiguration!
    var configurationObserverToken: NotificationToken?
    @Published var subViews = [HAViewType]()

    init(displayableModelObjectID: String) {
        configuration = displayableStore.vStackConfiguration(displayableModelObjectID: displayableModelObjectID)
        Task {
            await observeConfiguration()
            await mapSubViews()
        }
    }

    @MainActor
    func observeConfiguration() {
        configurationObserverToken = configuration.observe { [weak self] change in
            self?.mapSubViews()
        }
    }

    @MainActor
    func mapSubViews() {
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
            children
        }
    }

    var children: some View {
        ForEach(viewModel.subViews) { subview in
            HAViewBuilder().view(viewType: subview)
        }
    }
}
