import ApplicationConfiguration
import Combine
import Factory
import SwiftUI

class EntityConfigurationSettingsViewModel: ObservableObject {
    @Injected(\.sectionManager) private var sectionManager
    @Injected(\.config) private var configurationPublisher
    @Injected(\.websocket) private var homeAssistant
    @Injected(\.entityConfigurationManager) private var entityConfigurationManager

    @Published var configurations: [SectionInformation: [EntityConfiguration]] = [:]
    @Published var unmappedEntityConfigurations: [EntityConfiguration] = []
    @Published var sections: [SectionInformation] = []

    private var configurationList: [EntityConfiguration] = []
    private var sectionMap: [String: SectionInformation] = [:]

    private var isListenningForEntitites = false
    private var isListenningForEntitityConfiguration = false

    private var subscriptions = Set<AnyCancellable>()

    init() {
        listenForSectionConfiguration()
    }

    func listenForSectionConfiguration() {
        configurationPublisher
            .sectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                sections.forEach {
                    self?.configurations[$0] = .init()
                    self?.sectionMap[$0.id] = $0
                }
                self?.sections = sections
                self?.listenForEntitiesConfigurationIfNeeded()
            }
            .store (in: &subscriptions)
    }

    func listenForEntitiesConfigurationIfNeeded() {
        if isListenningForEntitityConfiguration { return }
        isListenningForEntitityConfiguration = true

        configurationPublisher
            .entityConfigurationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] configurations in
                self?.configurations = [:]
                self?.configurationList = configurations
                self?.unmappedEntityConfigurations = []

                configurations.forEach {
                    if let sectionID = $0.sectionID, let section = self?.sectionMap[sectionID] {
                        var values = self?.configurations[section]
                        values?.append($0)
                        self?.configurations[section] = values?.sorted(by: { lhs, rhs in
                            lhs.friendlyName ?? lhs.entityID < rhs.friendlyName ?? rhs.entityID
                        })
                    } else {
                        self?.unmappedEntityConfigurations.append($0)
                        self?.unmappedEntityConfigurations.sort(by: { lhs, rhs in
                            lhs.friendlyName ?? lhs.entityID < rhs.friendlyName ?? rhs.entityID
                        })
                    }
                }
                self?.listenForEnititiesIfNeeded()
            }
            .store (in: &subscriptions)
    }

    func listenForEnititiesIfNeeded() {
        if isListenningForEntitites { return }
        isListenningForEntitites = true
        homeAssistant.entityPublisher
            .sink { [weak self] entityState in
                if self?.configurationList.contains(where: { $0.entityID == entityState.entityId }) == false {
                    Task { [weak self] in
                        try! await self!.entityConfigurationManager.addConfiguration(.init(entityID: entityState.entityId))
                    }
                }
                self?.configurationList.first(where: {$0.entityID == entityState.entityId} )?.friendlyName = entityState.attributes.name
            }
            .store(in: &subscriptions)

    }
}

extension SectionInformation: Comparable {
    public static func < (lhs: SectionInformation, rhs: SectionInformation) -> Bool {
        return lhs.name < rhs.name
    }

}

struct EntityConfigurationSettingsView: View {
    @ObservedObject var viewModel: EntityConfigurationSettingsViewModel = .init()
    @State private var path: [EntityConfiguration] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(viewModel.sections) { section in
                    Section(section.name) {
                        List {
                            if viewModel.configurations[section] != nil {
                                ForEach(viewModel.configurations[section]!) { entity in
                                    NavigationLink(value: entity, label: {
                                        Text(entity.friendlyName ?? entity.entityID)
                                    })
                                    //                            .navigationDestination(for: SectionInformation.self) { section in
                                    //                                SectionDetailSettingsView(path: $path, sectionInformation: section)
                                    //                            }
                                }
                                .accentColor(ColorManager.haDefaultDark)
                            }
                        }
                    }
                }
                Section("New Entitites") {
                    ForEach($viewModel.unmappedEntityConfigurations) { entity in
                        NavigationLink(value: entity.wrappedValue) {
                            VStack(alignment: .leading) {
                                HAMainTextView(text: entity.wrappedValue.friendlyName ?? entity.wrappedValue.entityID)
                                if entity.wrappedValue.friendlyName != nil {
                                    HAFootNoteView(text: entity.wrappedValue.entityID)
                                }
                            }
                        }
//                        .navigationDestination(for: EntityConfiguration.self) { entity in
//                            EntityDetailConfigurationSettingsView(path: $path, entity: entity)
//                        }
                    }
                    .accentColor(ColorManager.haDefaultDark)
                }

            }
        }
    }
}
