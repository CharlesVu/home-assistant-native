import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class VStackConfigurationViewModel: ObservableObject {
    @Injected(\.databaseManager) var databaseManager
    @Injected(\.displayableStore) var displayableStore

    var sectionInformation: DisplayableModelObject
    var configuration: VStackConfiguration?

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
    var token: NotificationToken?

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
        configuration = displayableStore.vStackConfiguration(displayableModelObjectID: sectionInformation.id)

        token = configuration?.observe(keyPaths: ["children"]) { [weak self] _ in
            Task {
                await self?.updateDestinations()
            }
        }
        await updateDestinations()
    }

    @MainActor
    func updateDestinations() async {
        destinations = []
        if let children = configuration?.children {
            for element in children {
                if let destination = await HAVSettingsViewBuilder().map(model: element) {
                    destinations.append(destination)
                }
            }
        }
    }
}
