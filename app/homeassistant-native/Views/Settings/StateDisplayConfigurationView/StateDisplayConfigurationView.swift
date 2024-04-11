import ApplicationConfiguration
import Factory
import Foundation
import RealmSwift
import SwiftUI

class StateDisplayConfigurationViewModel: ObservableObject {
    @Injected(\.entityStore) var entityStore
    @Injected(\.displayableStore) var displayableStore

    var configuration: StateDisplayConfiguration?
    var path: Binding<NavigationPath>
    private var configurationObserverToken: NotificationToken?

    @Published var alignment: String {
        didSet {
            Task {
                await saveAlignment()
            }
        }
    }
    @Published var alignments = StateDisplayAlignment.allCases.map { $0.rawValue }
    @Published var name: String = ""

    init(path: Binding<NavigationPath>, configuration: StateDisplayConfiguration) {
        self.configuration = configuration
        self.path = path
        self.alignment = configuration.alignment.rawValue

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
}

struct StateDisplayConfigurationView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: StateDisplayConfigurationViewModel

    init(
        path: Binding<NavigationPath>,
        configuration: StateDisplayConfiguration
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
            }

            alignmentPicker
        }
        .navigationTitle("Button Configuration")
        .accentColor(themeManager.current.text)
    }

    var alignmentPicker: some View {
        Picker("Alignment", selection: $viewModel.alignment) {
            ForEach(viewModel.alignments, id: \.self) {
                Text($0.capitalized)
            }
        }
        .pickerStyle(.menu)
        .tint(themeManager.current.text)
    }
}
