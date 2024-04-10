import ApplicationConfiguration
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
                Divider()
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
