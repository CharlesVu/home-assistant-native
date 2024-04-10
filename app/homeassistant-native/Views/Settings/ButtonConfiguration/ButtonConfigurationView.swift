import ApplicationConfiguration
import Factory
import Foundation
import RealmSwift
import SwiftUI

class ButtonConfigurationViewModel: ObservableObject {
    @Injected(\.entityStore) var entityStore
    @Injected(\.displayableStore) var displayableStore

    var configuration: ButtonConfiguration
    var path: Binding<NavigationPath>
    var tokens: [NotificationToken] = []

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

        let token =
            configuration
            .observe({ changes in
                Task { [weak self] in
                    await self?.getEntityDetails()
                }
            })
        tokens.append(token)
    }

    @MainActor
    func getEntityDetails() async {
        if let entityID = configuration.entityID, let entity = await entityStore.entity(id: entityID) {
            self.name = "Entity: \(entity.displayName())"
        } else {
            self.name = "Select an entity"
        }
    }

    @MainActor
    func saveAlignment() async {
        await displayableStore.write {
            configuration.alignment = .init(rawValue: alignment)!
        }
    }

    @MainActor
    func saveMode() async {
        await displayableStore.write {
            configuration.mode = .init(rawValue: buttonMode)!
        }
    }
}

struct ButtonConfigurationView: View {
    @ObservedObject var viewModel: ButtonConfigurationViewModel

    init(
        path: Binding<NavigationPath>,
        configuration: ButtonConfiguration
    ) {
        viewModel = .init(path: path, configuration: configuration)
    }

    var body: some View {
        List {
            NavigationLink(
                value: NavigationDestination.selectEntity(owner: viewModel.configuration),
                label: {
                    Text(viewModel.name)
                }
            )

            alignmentPicker
            buttonModePicker
        }
        .navigationTitle("Button Configuration")
        .accentColor(ColorManager.haDefaultDark)
    }

    var alignmentPicker: some View {
        Picker("Alignment", selection: $viewModel.alignment) {
            ForEach(viewModel.alignments, id: \.self) {
                Text($0.capitalized)
            }
        }
        .pickerStyle(.menu)
        .tint(ColorManager.haDefaultDark)
    }

    var buttonModePicker: some View {
        Picker("Button Mode", selection: $viewModel.buttonMode) {
            ForEach(viewModel.buttonModes, id: \.self) {
                Text($0.capitalized)
            }
        }
        .pickerStyle(.menu)
        .tint(ColorManager.haDefaultDark)

    }
}
