import ApplicationConfiguration
import Combine
import Factory
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
    case vStackConfiguration(name: String, model: SectionModelObject)
    case buttonCongiguration(name: String, model: SectionModelObject)
}

class SectionDetailSettingsViewModel: ObservableObject {
    @Injected(\.databaseManager) var databaseManager
    @Published var sectionInformation: SectionModelObject

    @Published var name: String {
        didSet {
            validateInput()
        }
    }

    @Published var buttonTitle = "Save"
    @Published var isValid = false
    @Published var destinations = [Destination]()

    var path: Binding<NavigationPath>

    init(sectionInformation: SectionModelObject?, path: Binding<NavigationPath>) {
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
        do {
            try databaseManager.database().write {
                sectionInformation.name = name
                databaseManager.database().add(sectionInformation, update: .modified)
            }
            path.wrappedValue.removeLast()
        } catch {
            buttonTitle = "The Dev fucked up"
        }
    }

    @MainActor
    func getChildren() async {
        guard
            let configuration = databaseManager.database().object(
                ofType: VStackConfiguration.self,
                forPrimaryKey: sectionInformation.configurationID
            )
        else { return }

        destinations = []
        for element in configuration.children {
            if let destination = await build(model: element) {
                destinations.append(destination)
            }
        }
    }

    @MainActor
    func build(model: SectionModelObject) async -> Destination? {
        switch model.type {
            case .vStack:
                return .vStackConfiguration(name: model.name, model: model)
            case .button:
                guard
                    let configuration = databaseManager.database().object(
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
                return .buttonCongiguration(name: displayName, model: model)
        }
    }

}

struct VStackConfigurationView: View {
    @ObservedObject var viewModel: SectionDetailSettingsViewModel

    init(path: Binding<NavigationPath>, sectionInformation: SectionModelObject?) {
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
                        case .buttonCongiguration(let name, let model):
                            Text("Button")
                            Text(name)
                        case .vStackConfiguration(let name, let model):
                            NavigationLink(
                                value: NavigationDestination.sectionDetailSettingsView(sectionInformation: model),
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
