import ApplicationConfiguration
import RealmSwift
import SwiftUI

class HAStackViewModel: ObservableObject {
    private var displayableStore: (any DisplayableStoring)!

    var configuration: StackConfiguration!
    var configurationObserverToken: NotificationToken?
    @Published var subViews = [HAViewType]()
    @Published var alignment: StackAlignment = .horizontal
    private let displayableModelObjectID: String

    init(
        displayableModelObjectID: String
    ) {
        self.displayableModelObjectID = displayableModelObjectID
    }

    func set(displayableStore: any DisplayableStoring, entityStore: EntityStore) {
        self.displayableStore = displayableStore

        Task {
            configuration = await displayableStore.stackConfiguration(
                displayableModelObjectID: displayableModelObjectID
            )
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
    @EnvironmentObject private var entityStore: EntityStore
    @EnvironmentObject private var displayableStore: DisplayableStore

    init(displayableModelObjectID: String) {
        viewModel = .init(displayableModelObjectID: displayableModelObjectID)
    }

    var body: some View {
        if viewModel.alignment == .vertical {
            VStack(alignment: .leading) {
                children
            }
            .onAppear {
                viewModel.set(displayableStore: displayableStore, entityStore: entityStore)
            }
        } else {
            HStack(alignment: .top) {
                children
            }
            .onAppear {
                viewModel.set(displayableStore: displayableStore, entityStore: entityStore)
            }
        }

    }

    var children: some View {
        ForEach(viewModel.subViews) { subview in
            HAViewBuilder().view(viewType: subview)
        }
    }
}
