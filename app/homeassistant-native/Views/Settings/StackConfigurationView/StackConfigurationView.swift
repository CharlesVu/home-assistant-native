import ApplicationConfiguration
import SwiftUI

struct StackConfigurationView: View {
    @ObservedObject var viewModel: StackConfigurationViewModel

    init(
        path: Binding<NavigationPath>,
        sectionInformation: DisplayableModelObject
    ) {
        viewModel = .init(sectionInformation: sectionInformation, path: path)
    }

    var body: some View {
        List {
            Section("Section Name") {
                TextField("Name", text: $viewModel.name)
                alignmentModePicker
            }
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

            }.onDelete { index in
                Task { await viewModel.delete(at: index) }
            }
        }
    }
    var alignmentModePicker: some View {
        Picker("Alignment", selection: $viewModel.alignment) {
            ForEach(viewModel.alignments, id: \.self) {
                Text($0.capitalized)
            }
        }
        .pickerStyle(.menu)
        .tint(ColorManager.haDefaultDark)

    }

}
