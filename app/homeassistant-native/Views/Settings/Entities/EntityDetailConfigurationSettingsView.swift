import ApplicationConfiguration
import Combine
import Factory
import SwiftUI

class EntityDetailConfigurationSettingsViewModel: ObservableObject {
    @Injected(\.entityConfigurationManager) private var entityManager

    @Published var entityConfiguration: EntityConfiguration
    @Published var sectionID: String
    @Published var position: String
    @Published var buttonTitle = "Save"
    @Published var isValid = false

    var path: Binding<NavigationPath>

    init(entityConfiguration: EntityConfiguration, path: Binding<NavigationPath>) {
        self.entityConfiguration = entityConfiguration
        self.sectionID = entityConfiguration.sectionID ?? ""
        self.position = entityConfiguration.position
        self.path = path
    }

    @MainActor
    func save() async {
        do {
            entityConfiguration.sectionID = sectionID
            entityConfiguration.position = position
            try await entityManager.addConfiguration(entityConfiguration)
            path.wrappedValue.removeLast()
        } catch {
            buttonTitle = "The Dev fucked up"
        }
    }
}

struct EntityDetailConfigurationSettingsView: View {
    @ObservedObject var viewModel: EntityDetailConfigurationSettingsViewModel

    init(path: Binding<NavigationPath>, entityConfiguration: EntityConfiguration) {
        viewModel = .init(entityConfiguration: entityConfiguration, path: path)
    }

    var body: some View {
        Form {
            Section("sectionID") {
                TextField("Name", text: $viewModel.sectionID)
            }
            Section("Position") {
                TextField("1", text: $viewModel.position)
            }
            Button(viewModel.buttonTitle) {
                Task {
                    await viewModel.save()
                }
            }
            .disabled(!viewModel.isValid)
            .transition(.opacity)
            .accentColor(ColorManager.haDefaultDark)
        }
        .navigationTitle(viewModel.entityConfiguration.friendlyName ?? viewModel.entityConfiguration.entityID)
        .accentColor(ColorManager.haDefaultDark)
    }
}
