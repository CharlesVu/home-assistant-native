import ApplicationConfiguration
import SwiftUI

enum HAViewType: Identifiable {
    var id: String {
        switch self {
            case .stack(let id):
                return id
            case .button(let id):
                return id
            case .state(let id):
                return id
            case .octopus:
                return "octopus"

        }
    }

    case state(id: String)
    case stack(id: String)
    case button(id: String)
    case octopus
}

struct HAViewBuilder {
    @ViewBuilder func view(viewType: HAViewType) -> some View {
        switch viewType {
            case .stack(let id):
                HAStack(displayableModelObjectID: id)
            case .button(let id):
                HAButton(displayableModelObjectID: id)
            case .state(let id):
                HAEntityView(displayableModelObjectID: id)
            case .octopus:
                OctopusPriceListView()
        }
    }

    func map(model: DisplayableModelObject) -> HAViewType? {
        switch model.type {
            case .stack:
                return .stack(id: model.id)
            case .button:
                return .button(id: model.id)
            case .stateDisplay:
                return .state(id: model.id)
            case .octopus:
                return .octopus
        }
    }
}
