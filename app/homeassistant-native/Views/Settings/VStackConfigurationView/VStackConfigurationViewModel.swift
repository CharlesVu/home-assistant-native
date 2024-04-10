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
            Task {
                await saveName()
            }
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

    func saveName() async {
        await displayableStore.write {
            sectionInformation.name = name
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
