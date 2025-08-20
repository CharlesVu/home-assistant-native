import ApplicationConfiguration
import SwiftUI

struct StackConfigurationView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var entityStore: EntityStore
    @EnvironmentObject private var displayableStore: DisplayableStore
    @EnvironmentObject private var databaseProvider: PersistantRealmProvider
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
                    .listRowBackground(themeManager.current.lightBackground)
                alignmentModePicker
            }
            children
            NavigationLink(
                value: NavigationDestination.addWidget(parent: viewModel.sectionInformation),
                label: {
                    Text("Add a widget")
                }
            )
            .listRowBackground(themeManager.current.lightBackground)
        }
        .background(themeManager.current.background)
        .scrollContentBackground(.hidden)
        .navigationTitle("Vertical Stack")
        .accentColor(themeManager.current.text)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.set(
                databaseProvider: databaseProvider,
                displayableStore: displayableStore,
                entityStore: entityStore
            )
        }
    }

    var children: some View {
        Section("Embeded Widgets (drag to reorder)") {
            ForEach(viewModel.destinations) { child in
                HStack {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(themeManager.current.text)
                    HAVSettingsViewBuilder(entityStore: entityStore, displayableStore: displayableStore).view(
                        viewType: child
                    )
                }
            }.onDelete { index in
                Task { await viewModel.delete(at: index) }
            }.onMove { source, destination in
                Task { await viewModel.move(from: source, to: destination) }
            }
            .listRowBackground(themeManager.current.lightBackground)
        }
    }
    var alignmentModePicker: some View {
        Picker("Alignment", selection: $viewModel.alignment) {
            ForEach(viewModel.alignments, id: \.self) {
                Text($0.capitalized)
            }
        }
        .pickerStyle(.menu)
        .tint(themeManager.current.text)
        .listRowBackground(themeManager.current.lightBackground)
    }

}
