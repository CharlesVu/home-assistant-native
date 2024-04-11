import ApplicationConfiguration
import Factory
import Foundation
import SwiftUI

enum SettingDestination: Identifiable {
    var id: ObjectIdentifier {
        switch self {
            case .vStackConfiguration(_, let model):
                return model.id
            case .buttonCongiguration(_, let model):
                return model.id
        }
    }

    case vStackConfiguration(name: String, model: DisplayableModelObject)
    case buttonCongiguration(name: String, configuration: ButtonConfiguration)
}

struct HAVSettingsViewBuilder {
    @Injected(\.entityStore) var entityStore
    @Injected(\.displayableStore) var displayableStore

    @ViewBuilder func view(viewType: SettingDestination) -> some View {
        switch viewType {
            case .buttonCongiguration(let name, let configuration):
                NavigationLink(
                    value: NavigationDestination.buttonConfiguration(configuration: configuration),
                    label: {
                        Text(name)
                    }
                )
            case .vStackConfiguration(let name, let model):
                NavigationLink(
                    value: NavigationDestination.vStackConfiguration(sectionInformation: model),
                    label: {
                        Text(name)
                    }
                )
        }
    }

    @MainActor
    func map(model: DisplayableModelObject) async -> SettingDestination? {
        switch model.type {
            case .vStack:
                let configuration = displayableStore.vStackConfiguration(displayableModelObjectID: model.id)

                return .vStackConfiguration(
                    name: "\(configuration.alignment.rawValue.capitalized) Stack: \(model.name)",
                    model: model
                )
            case .button:
                let configuration = displayableStore.buttonConfiguration(displayableModelObjectID: model.id)

                var displayName = "Not configured"
                if let id = configuration.entityID, let entity = await entityStore.entity(id: id) {
                    displayName = "Button: \(entity.displayName())"
                }
                return .buttonCongiguration(name: displayName, configuration: configuration)
        }

    }
}
