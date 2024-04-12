import ApplicationConfiguration
import SwiftUI

enum NavigationDestination: Hashable {
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
            case (.sectionsSettingsView, .sectionsSettingsView):
                return true
            case (.stackConfiguration(let lhsConfiguration), .stackConfiguration(let rhsConfiguration)):
                return lhsConfiguration == rhsConfiguration
            case (.addWidget(let lhsParent), .addWidget(let rhsParent)):
                return lhsParent == rhsParent
            case (.selectEntity(let lhsOwner), .selectEntity(let rhsOwner)):
                return lhsOwner.entityID == rhsOwner.entityID
            case (.buttonConfiguration(let lhs), .buttonConfiguration(let rhs)):
                return lhs.id == rhs.id
            case (.stateDisplayConfiguration(let lhs), .stateDisplayConfiguration(let rhs)):
                return lhs.id == rhs.id

            default:
                return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
            case .sectionsSettingsView:
                hasher.combine("sectionsSettingsView")
            case .stackConfiguration(let configuration):
                hasher.combine("stackConfiguration")
                hasher.combine(configuration)
            case .addWidget(let parent):
                hasher.combine("addWidget")
                hasher.combine(parent)
            case .selectEntity(let owner):
                hasher.combine("selectEntity")
                hasher.combine(owner)
            case .buttonConfiguration(let configuration):
                hasher.combine("buttonConfiguration")
                hasher.combine(configuration)
            case .stateDisplayConfiguration(let configuration):
                hasher.combine("stateDisplayConfiguration")
                hasher.combine(configuration)

        }
    }

    case sectionsSettingsView
    case stackConfiguration(sectionInformation: DisplayableModelObject)
    case addWidget(parent: DisplayableModelObject)
    case buttonConfiguration(configuration: ButtonConfiguration)
    case selectEntity(owner: any EntityAttachable)
    case stateDisplayConfiguration(configuration: StateDisplayConfiguration)

    @ViewBuilder func view(_ path: Binding<NavigationPath>) -> some View {
        switch self {
            case .sectionsSettingsView:
                RootConfigurationView(path: path)
            case .stackConfiguration(let sectionInformation):
                StackConfigurationView(path: path, sectionInformation: sectionInformation)
            case .addWidget(let parent):
                AddWidgetView(path: path, parent: parent)
            case .selectEntity(let owner):
                EntitySelectionView(path: path, entityAttachable: owner)
            case .buttonConfiguration(let configuration):
                ButtonConfigurationView(path: path, configuration: configuration)
            case .stateDisplayConfiguration(let configuration):
                StateDisplayConfigurationView(path: path, configuration: configuration)
        }
        EmptyView()
    }
}

struct ModalSettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var path: NavigationPath = .init()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 0) {
                List {
                    Section("Display") {
                        NavigationLink(value: NavigationDestination.sectionsSettingsView) {
                            HASettingItemView(
                                text: "Sections",
                                icon: "list.dash.header.rectangle",
                                foregroundColor: .accentColor,
                                backgroundColor: .white
                            )
                        }
                    }
                    .listRowBackground(themeManager.current.lightBackground)
                    Section {
                        NavigationLink {
                            HomeAssistantSettingsView()
                        } label: {
                            HASettingItemView(
                                text: "Home Assistant",
                                icon: "house.fill",
                                foregroundColor: .blue,
                                backgroundColor: .white
                            )
                        }
                    }
                    .listRowBackground(themeManager.current.lightBackground)

                }
                .background(themeManager.current.background)
                .scrollContentBackground(.hidden)
            }
            .navigationDestination(for: NavigationDestination.self) { option in
                option.view($path)
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Settings")
            #if !os(macOS)
            .navigationBarItems(
                trailing:
                    Button(
                        "Dismiss",
                        action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    )
                    .accentColor(themeManager.current.text)
            )
            #endif
        }
        .tint(themeManager.current.text)
    }
}

struct ModalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ModalSettingsView()
    }
}
