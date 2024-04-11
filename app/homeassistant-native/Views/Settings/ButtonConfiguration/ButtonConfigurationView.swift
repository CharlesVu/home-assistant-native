import ApplicationConfiguration
import Factory
import Foundation
import RealmSwift
import SwiftUI

class ButtonConfigurationViewModel: ObservableObject {
    @Injected(\.entityStore) var entityStore
    @Injected(\.displayableStore) var displayableStore

    var configuration: ButtonConfiguration?
    var path: Binding<NavigationPath>
    private var configurationObserverToken: NotificationToken?

    @Published var alignment: String {
        didSet {
            Task {
                await saveAlignment()
            }
        }
    }
    @Published var alignments = ButtonAlignment.allCases.map { $0.rawValue }
    @Published var name: String = ""
    @Published var buttonMode: String {
        didSet {
            Task {
                await saveMode()
            }
        }
    }
    @Published var buttonModes = ButtonMode.allCases.map { $0.rawValue }

    init(path: Binding<NavigationPath>, configuration: ButtonConfiguration) {
        self.configuration = configuration
        self.path = path
        self.alignment = configuration.alignment.rawValue
        self.buttonMode = configuration.mode.rawValue

        Task {
            await getEntityDetails()
        }

        configurationObserverToken = displayableStore.observe(
            configuration,
            onChange: { [weak self] in
                await self?.getEntityDetails()
            },
            onDelete: { [weak self] in
                self?.configuration = nil
                self?.configurationObserverToken = nil
            }
        )
    }

    @MainActor
    func getEntityDetails() async {
        guard let configuration else { return }

        if let entityID = configuration.entityID, let entity = await entityStore.entity(id: entityID) {
            self.name = "Entity: \(entity.displayName())"
        } else {
            self.name = "Select an entity"
        }
    }

    @MainActor
    func saveAlignment() async {
        guard let configuration else { return }

        await displayableStore.write {
            configuration.alignment = .init(rawValue: alignment)!
        }
    }

    @MainActor
    func saveMode() async {
        guard let configuration else { return }

        await displayableStore.write {
            configuration.mode = .init(rawValue: buttonMode)!
        }
    }
}

struct ButtonConfigurationView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: ButtonConfigurationViewModel

    init(
        path: Binding<NavigationPath>,
        configuration: ButtonConfiguration
    ) {
        viewModel = .init(path: path, configuration: configuration)
    }

    var body: some View {
        List {
            if let configuration = viewModel.configuration {
                NavigationLink(
                    value: NavigationDestination.selectEntity(owner: configuration),
                    label: {
                        Text(viewModel.name)
                    }
                )
                .listRowBackground(themeManager.current.lightBackground)
            }

            alignmentPicker
            buttonModePicker
        }
        .background(themeManager.current.background)
        .scrollContentBackground(.hidden)
        .navigationTitle("Button Configuration")
        .accentColor(themeManager.current.text)
        .navigationBarTitleDisplayMode(.large)
    }

    var alignmentPicker: some View {
        Picker("Alignment", selection: $viewModel.alignment) {
            ForEach(viewModel.alignments, id: \.self) {
                Text($0.capitalized)
            }
        }
        .pickerStyle(.menu)
        .tint(themeManager.current.text)
        .listRowBackground(themeManager.current.lightBackground)
    }

    var buttonModePicker: some View {
        Picker("Button Mode", selection: $viewModel.buttonMode) {
            ForEach(viewModel.buttonModes, id: \.self) {
                Text($0.capitalized)
            }
        }
        .pickerStyle(.menu)
        .tint(themeManager.current.text)
        .listRowBackground(themeManager.current.lightBackground)
    }
}
