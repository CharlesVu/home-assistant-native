import ApplicationConfiguration
import Foundation
import SwiftUI

enum SettingDestination: Identifiable {
    var id: String {
        switch self {
            case .stackConfiguration(_, let model):
                return model.id
            case .buttonCongiguration(_, let model):
                return model.id
            case .stateDisplayConfiguration(_, let model):
                return model.id
            case .octopus:
                return "octopus"
        }
    }

    case stackConfiguration(name: String, model: DisplayableModelObject)
    case buttonCongiguration(name: String, configuration: ButtonConfiguration)
    case stateDisplayConfiguration(name: String, configuration: StateDisplayConfiguration)
    case octopus

}

struct HAVSettingsViewBuilder {
    private let entityStore: any EntityStoring
    private let displayableStore: any DisplayableStoring

    init(entityStore: any EntityStoring, displayableStore: any DisplayableStoring) {
        self.entityStore = entityStore
        self.displayableStore = displayableStore
    }

    @ViewBuilder func view(viewType: SettingDestination) -> some View {
        switch viewType {
            case .buttonCongiguration(let name, let configuration):
                NavigationLink(
                    value: NavigationDestination.buttonConfiguration(configuration: configuration),
                    label: {
                        Text(name)
                    }
                )
            case .stateDisplayConfiguration(let name, let configuration):
                NavigationLink(
                    value: NavigationDestination.stateDisplayConfiguration(configuration: configuration),
                    label: {
                        Text(name)
                    }
                )

            case .stackConfiguration(let name, let model):
                NavigationLink(
                    value: NavigationDestination.stackConfiguration(sectionInformation: model),
                    label: {
                        Text(name)
                    }
                )
            case .octopus:
                HADetailTextView(text: "Octopus", textAlignment: .leading)
        }
    }

    @MainActor
    func map(model: DisplayableModelObject) async -> SettingDestination? {
        switch model.type {
            case .stack:
                let configuration = await displayableStore.stackConfiguration(displayableModelObjectID: model.id)

                return .stackConfiguration(
                    name: "\(configuration.alignment.rawValue.capitalized) Stack: \(model.name)",
                    model: model
                )
            case .button:
                let configuration = await displayableStore.buttonConfiguration(displayableModelObjectID: model.id)

                var displayName = "Not configured"
                if let id = configuration.entityID, let entity = await entityStore.entity(id: id) {
                    displayName = "Button: \(entity.displayName())"
                }
                return .buttonCongiguration(name: displayName, configuration: configuration)
            case .stateDisplay:
                let configuration = await displayableStore.stateDisplayConfiguration(displayableModelObjectID: model.id)

                var displayName = "Not configured"
                if let id = configuration.entityID, let entity = await entityStore.entity(id: id) {
                    displayName = "State: \(entity.displayName())"
                }
                return .stateDisplayConfiguration(name: displayName, configuration: configuration)
            case .octopus:
                return .octopus
        }

    }
}
