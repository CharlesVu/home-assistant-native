import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class VStackConfigurationViewModel: ObservableObject {
    @Injected(\.databaseManager) var databaseManager
    @Injected(\.displayableStore) var displayableStore

    var sectionInformation: DisplayableModelObject

    @Published var name: String {
        didSet {
            validateInput()
        }
    }

    @Published var buttonTitle = "Save"
    @Published var isValid = false
    @Published var destinations = [SettingDestination]()

    var path: Binding<NavigationPath>
    var tokens: [NotificationToken] = []

    init(sectionInformation: DisplayableModelObject, path: Binding<NavigationPath>) {
        self.sectionInformation = sectionInformation.thaw()!
        self.name = sectionInformation.name

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
        let configuration = displayableStore.vStackConfiguration(displayableModelObjectID: sectionInformation.id)

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
            if let destination = await HAVSettingsViewBuilder().map(model: element) {
                destinations.append(destination)
            }
        }
    }
}
