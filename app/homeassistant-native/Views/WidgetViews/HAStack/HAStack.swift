import ApplicationConfiguration
import Factory
import RealmSwift
import SwiftUI

class HAStackViewModel: ObservableObject {
    @Injected(\.displayableStore) var displayableStore
    var configuration: StackConfiguration!
    var configurationObserverToken: NotificationToken?
    @Published var subViews = [HAViewType]()
    @Published var alignment: StackAlignment = .horizontal

    init(displayableModelObjectID: String) {
        configuration = displayableStore.stackConfiguration(displayableModelObjectID: displayableModelObjectID)
        Task {
            await updateAlignment()
            await observeConfiguration()
            await mapSubViews()
        }
    }

    @MainActor
    func observeConfiguration() {
        configurationObserverToken = displayableStore.observe(
            configuration,
            onChange: { [weak self] in
                self?.mapSubViews()
                self?.updateAlignment()
            },
            onDelete: { [weak self] in
                self?.configuration = nil
                self?.configurationObserverToken = nil
            }
        )
    }

    @MainActor
    func updateAlignment() {
        alignment = configuration.alignment
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

struct HAStack: View {
    @ObservedObject var viewModel: HAStackViewModel

    init(displayableModelObjectID: String) {
        viewModel = .init(displayableModelObjectID: displayableModelObjectID)
    }

    var body: some View {
        if viewModel.alignment == .vertical {
            VStack(alignment: .leading) {
                children
            }
        } else {
            HStack(alignment: .top) {
                children
            }
        }
    }

    var children: some View {
        ForEach(viewModel.subViews) { subview in
            HAViewBuilder().view(viewType: subview)
        }
    }
}
