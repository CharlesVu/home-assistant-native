import ApplicationConfiguration
import SwiftUI

struct VStackConfigurationView: View {
    @ObservedObject var viewModel: VStackConfigurationViewModel

    init(
        path: Binding<NavigationPath>,
        sectionInformation: DisplayableModelObject
    ) {
        viewModel = .init(sectionInformation: sectionInformation, path: path)
    }

    var body: some View {
        Form {
            Section("Section Name") {
                TextField("Name", text: $viewModel.name)
            }
            Button(viewModel.buttonTitle) {
                Task {
                    await viewModel.save()
                }
            }
            .disabled(!viewModel.isValid)
            .transition(.opacity)
            .accentColor(ColorManager.haDefaultDark)
            children
            NavigationLink(
                value: NavigationDestination.addWidget(parent: viewModel.sectionInformation),
                label: {
                    Text("Add a widget")
                }
            )

        }
        .navigationTitle("Vertical Stack")
        .accentColor(ColorManager.haDefaultDark)
    }

    var children: some View {
        Section("Embeded Widgets") {
            ForEach(viewModel.destinations) { child in
                HAVSettingsViewBuilder().view(viewType: child)
            }
        }
    }
}
