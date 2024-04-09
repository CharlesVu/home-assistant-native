import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

enum Destination: Identifiable {
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

class SectionDetailSettingsViewModel: ObservableObject {
    @Injected(\.databaseManager) var databaseManager
    @Published var sectionInformation: DisplayableModelObject

    @Published var name: String {
        didSet {
            validateInput()
        }
    }

    @Published var buttonTitle = "Save"
    @Published var isValid = false
    @Published var destinations = [Destination]()

    var path: Binding<NavigationPath>
    var tokens: [NotificationToken] = []

    init(sectionInformation: DisplayableModelObject?, path: Binding<NavigationPath>) {
        if let sectionInformation {
            self.sectionInformation = sectionInformation.thaw()!
            self.name = sectionInformation.name

        } else {
            self.sectionInformation = .init()
            self.name = ""
        }
        self.path = path
        Task {
            await getChildren()
        }
    }

    func validateInput() {
        isValid = name != ""
    }

    @MainActor
    func save() async {
        let db = databaseManager.database()
        do {
            try await db.asyncWrite {
                sectionInformation.name = name
                db.add(sectionInformation, update: .modified)
            }
            path.wrappedValue.removeLast()
        } catch {
            buttonTitle = "The Dev fucked up"
        }
    }

    @MainActor
    func getChildren() async {
        let db = databaseManager.database()

        guard
            let configuration = db.object(
                ofType: VStackConfiguration.self,
                forPrimaryKey: sectionInformation.configurationID
            )
        else { return }

        let token = configuration.observe(keyPaths: ["children"]) { change in
            switch change {
                case .change(let object, _):
                    if let object = object as? VStackConfiguration {
                        Task { [weak self] in
                            await self?.updateDestinations(configuration: object)
                        }
                    }
                default:
                    ()
            }
        }
        tokens.append(token)
        await updateDestinations(configuration: configuration)
    }

    @MainActor
    func updateDestinations(configuration: VStackConfiguration) async {
        destinations = []
        for element in configuration.children {
            if let destination = await build(model: element) {
                destinations.append(destination)
            }
        }

    }

    @MainActor
    func build(model: DisplayableModelObject) async -> Destination? {
        switch model.type {
            case .vStack:
                return .vStackConfiguration(name: model.name, model: model)
            case .button:
                let db = databaseManager.database()

                guard
                    let configuration = db.object(
                        ofType: ButtonConfiguration.self,
                        forPrimaryKey: model.configurationID
                    )
                else {
                    return nil
                }

                var displayName = "Not configured"
                if let id = configuration.entityID, let entity = await databaseManager.entity(id: id) {
                    displayName = entity.displayName()
                }
                return .buttonCongiguration(name: displayName, configuration: configuration)
        }
    }

}

struct VStackConfigurationView: View {
    @ObservedObject var viewModel: SectionDetailSettingsViewModel

    init(path: Binding<NavigationPath>, sectionInformation: DisplayableModelObject?) {
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
                    Text("Add")
                }
            )

        }
        .navigationTitle("Section")
        .accentColor(ColorManager.haDefaultDark)
    }

    var children: some View {
        Group {
            Section("Children") {
                ForEach(viewModel.destinations) { child in
                    switch child {
                        case .buttonCongiguration(let name, let configuration):
                            NavigationLink(
                                value: NavigationDestination.selectEntity(owner: configuration),
                                label: {
                                    Text(name)
                                }
                            )
                        case .vStackConfiguration(let name, let model):
                            NavigationLink(
                                value: NavigationDestination.vStackConfiguration(sectionInformation: model),
                                label: {
                                    Text(model.name)
                                }
                            )

                    }
                }
            }
        }
    }
}
