import ApplicationConfiguration
import SwiftUI

enum HAViewType: Identifiable {
    var id: String {
        switch self {
            case .stack(let id):
                return id
            case .button(let id):
                return id
        }
    }

    case stack(id: String)
    case button(id: String)
}

struct HAViewBuilder {
    @ViewBuilder func view(viewType: HAViewType) -> some View {
        switch viewType {
            case .stack(let id):
                HAStack(displayableModelObjectID: id)
            case .button(let id):
                HAButton(displayableModelObjectID: id)
        }
    }

    func map(model: DisplayableModelObject) -> HAViewType? {
        switch model.type {
            case .stack:
                return .stack(id: model.id)
            case .button:
                return .button(id: model.id)
        }
    }
}
