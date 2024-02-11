import ApplicationConfiguration
import Combine
import Factory
import SwiftUI

class EntityDetailConfigurationSettingsViewModel: ObservableObject {
    @Published var sectionID: String = ""
    @Published var position: String
    @Published var buttonTitle = "Save"

    var path: Binding<NavigationPath>

    init(
        entityConfiguration: EntityConfiguration,
        path: Binding<NavigationPath>,
        sections: [SectionInformation]
    ) {
        self.entityConfiguration = entityConfiguration
        self.sectionID = entityConfiguration.sectionID ?? ""
        self.position = entityConfiguration.position
        self.path = path
        self.sections = sections
        self.sections.insert(SectionInformation(), at: 0)
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

    init(
        path: Binding<NavigationPath>,
        entityConfiguration: EntityConfiguration,
        sections: [SectionInformation]
    ) {
        viewModel = .init(entityConfiguration: entityConfiguration, path: path, sections: sections)
    }

    var body: some View {
        Form {
            Section("sectionID") {
                Picker("Select a Section", selection: $viewModel.sectionID) {
                    ForEach(viewModel.sections) {
                        Text($0.name)
                    }
                }
                .pickerStyle(.menu)
            }
            Section("Position") {
                TextField("1", text: $viewModel.position)
            }
            Button(viewModel.buttonTitle) {
                Task {
                    await viewModel.save()
                }
            }
            .transition(.opacity)
            .accentColor(ColorManager.haDefaultDark)
        }
        .navigationTitle(viewModel.entityConfiguration.friendlyName ?? viewModel.entityConfiguration.entityID)
        .accentColor(ColorManager.haDefaultDark)
    }
}
