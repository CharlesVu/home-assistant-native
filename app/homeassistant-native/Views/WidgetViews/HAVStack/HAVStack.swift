import ApplicationConfiguration
import Factory
import RealmSwift
import SwiftUI

enum HAViewType: Identifiable {
    var id: String {
        switch self {
            case .vStack(let id):
                return id
            case .button(let id):
                return id
        }
    }

    case vStack(id: String)
    case button(id: String)
}

struct HAViewBuilder {
    @ViewBuilder func view(viewType: HAViewType) -> some View {
        switch viewType {
            case .vStack(let id):
                HAVStack(displayableModelObjectID: id)
            case .button(let id):
                HAButton(displayableModelObjectID: id)
        }
    }

    func map(model: DisplayableModelObject) -> HAViewType? {
        switch model.type {
            case .vStack:
                return .vStack(id: model.id)
            case .button:
                return .button(id: model.id)
        }
    }
}

class HAVStackViewModel: ObservableObject {
    @Injected(\.databaseManager) var databaseManager
    var displayable: DisplayableModelObject!
    var configuration: VStackConfiguration!
    var tokens: [NotificationToken] = []
    @Published var subViews = [HAViewType]()

    init(displayableModelObjectID: String) {
        displayable = databaseManager.database().object(
            ofType: DisplayableModelObject.self,
            forPrimaryKey: displayableModelObjectID
        )!
        configuration = databaseManager.database().object(
            ofType: VStackConfiguration.self,
            forPrimaryKey: displayable.configurationID
        )!
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
        }
    }
}
