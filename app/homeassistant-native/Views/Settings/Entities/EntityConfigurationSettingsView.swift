import ApplicationConfiguration
import Combine
import Factory
import SwiftUI

class EntityConfigurationSettingsViewModel: ObservableObject {
    @Injected(\.config) private var configurationPublisher
    @Injected(\.websocket) private var homeAssistant

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
            .store(in: &subscriptions)
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
            .store(in: &subscriptions)
    }

    func listenForEnititiesIfNeeded() {
        if isListenningForEntitites { return }
        isListenningForEntitites = true
        homeAssistant.entityPublisher
            .sink { [weak self] entityState in
                if self?.configurationList.contains(where: { $0.entityID == entityState.entityId }) == false {
                    Task { [weak self] in
                        try! await self!.entityConfigurationManager.addConfiguration(
                            .init(entityID: entityState.entityId)
                        )
                    }
                }
                self?.configurationList.first(where: { $0.entityID == entityState.entityId })?
                    .friendlyName =
                    entityState.attributes.name
            }
            .store(in: &subscriptions)
    }

    func getConfigurationByID(_ entityID: String) -> EntityConfiguration {
        configurationList.first(where: { $0.entityID == entityID })!
    }
}

struct EntityConfigurationSettingsView: View {
    @ObservedObject var viewModel: EntityConfigurationSettingsViewModel = .init()
    var path: Binding<NavigationPath>

    var body: some View {
        List {
            ForEach(viewModel.sections) { section in
                Section(section.name) {
                    List {
                        if viewModel.configurations[section] != nil {
                            ForEach(viewModel.configurations[section]!) { entity in
                                NavigationLink(
                                    value: NavigationDestination.entityConfigurationDetailSettingsView(
                                        entityConfiguration: entity,
                                        sections: viewModel.sections
                                    ),
                                    label: {
                                        Text(entity.friendlyName ?? entity.entityID)
                                    }
                                )
                            }
                            .accentColor(ColorManager.haDefaultDark)
                        }
                    }
                }
            }
            Section("New Entitites") {
                ForEach($viewModel.unmappedEntityConfigurations) { entity in
                    NavigationLink(
                        value: NavigationDestination.entityConfigurationDetailSettingsView(
                            entityConfiguration: entity.wrappedValue,
                            sections: viewModel.sections
                        )
                    ) {
                        VStack(alignment: .leading) {
                            HAMainTextView(text: entity.wrappedValue.friendlyName ?? entity.wrappedValue.entityID)
                            if entity.wrappedValue.friendlyName != nil {
                                HAFootNoteView(text: entity.wrappedValue.entityID, alignement: .leading)
                            }
                        }
                    }
                }
                .accentColor(ColorManager.haDefaultDark)
            }
        }
    }
}
