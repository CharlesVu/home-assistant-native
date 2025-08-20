import ApplicationConfiguration
import Combine
import RealmSwift
import SwiftUI

class StackConfigurationViewModel: ObservableObject {
    private var databaseProvider: (any RealmProviding)!
    private var displayableStore: (any DisplayableStoring)!
    private var entityStore: (any EntityStoring)!

    var sectionInformation: DisplayableModelObject
    private var configuration: StackConfiguration?

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
    @Published var alignment: String = "horizontal" {
        didSet {
            Task {
                await saveAlignment()
            }
        }
    }
    @Published var alignments = ButtonAlignment.allCases.map { $0.rawValue }

    var path: Binding<NavigationPath>
    var configurationObserverToken: NotificationToken?

    init(sectionInformation: DisplayableModelObject, path: Binding<NavigationPath>) {
        self.sectionInformation = sectionInformation.thaw()!
        self.name = sectionInformation.name

        self.path = path
    }

    func set(
        databaseProvider: any RealmProviding,
        displayableStore: any DisplayableStoring,
        entityStore: any EntityStoring
    ) {
        self.databaseProvider = databaseProvider
        self.displayableStore = displayableStore
        self.entityStore = entityStore
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
        configuration = await displayableStore.stackConfiguration(displayableModelObjectID: sectionInformation.id)
        alignment = configuration!.alignment.rawValue
        configurationObserverToken = displayableStore.observe(
            configuration,
            onChange: { [weak self] in
                await self?.updateDestinations()
            },
            onDelete: { [weak self] in
                self?.configuration = nil
                self?.configurationObserverToken = nil
            }
        )

        await updateDestinations()
    }

    @MainActor
    func updateDestinations() async {
        destinations = []
        if let children = configuration?.children {
            for element in children {
                if let destination = await HAVSettingsViewBuilder(
                    entityStore: entityStore,
                    displayableStore: displayableStore
                ).map(model: element) {
                    destinations.append(destination)
                }
            }
        }
    }

    @MainActor
    func saveAlignment() async {
        await displayableStore.write {
            configuration?.alignment = .init(rawValue: alignment)!
        }
    }

    @MainActor
    func delete(at offsets: IndexSet) async {
        let itemsToDelete = offsets.compactMap { configuration?.children[$0] }
        await displayableStore.delete(itemsToDelete)
    }

    @MainActor
    func move(from: IndexSet, to: Int) async {
        await displayableStore.write {
            configuration?.children.move(fromOffsets: from, toOffset: to)
        }
    }
}
