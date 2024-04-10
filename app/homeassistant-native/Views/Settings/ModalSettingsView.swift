import ApplicationConfiguration
import SwiftUI

enum NavigationDestination: Hashable {
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
            case (.sectionsSettingsView, .sectionsSettingsView):
                return true
            case (.vStackConfiguration(let lhsConfiguration), .vStackConfiguration(let rhsConfiguration)):
                return lhsConfiguration == rhsConfiguration
            case (.addWidget(let lhsParent), .addWidget(let rhsParent)):
                return lhsParent == rhsParent
            case (.selectEntity(let lhsOwner), .selectEntity(let rhsOwner)):
                return lhsOwner.entityID == rhsOwner.entityID
            case (.buttonConfiguration(let lhs), .buttonConfiguration(let rhs)):
                return lhs.id == rhs.id
            default:
                return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
            case .sectionsSettingsView:
                hasher.combine("sectionsSettingsView")
            case .vStackConfiguration(let configuration):
                hasher.combine("vStackConfiguration")
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
        }
    }

    case sectionsSettingsView
    case vStackConfiguration(sectionInformation: DisplayableModelObject)
    case addWidget(parent: DisplayableModelObject)
    case buttonConfiguration(configuration: ButtonConfiguration)
    case selectEntity(owner: any EntityAttachable)

    @ViewBuilder func view(_ path: Binding<NavigationPath>) -> some View {
        switch self {
            case .sectionsSettingsView:
                RootConfigurationView(path: path)
            case .vStackConfiguration(let sectionInformation):
                VStackConfigurationView(path: path, sectionInformation: sectionInformation)
            case .addWidget(let parent):
                AddWidgetView(path: path, parent: parent)
            case .selectEntity(let owner):
                EntitySelectionView(path: path, entityAttachable: owner)
            case .buttonConfiguration(let configuration):
                ButtonConfigurationView(path: path, configuration: configuration)
        }
        EmptyView()
    }
}

struct ModalSettingsView: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>
    @State private var path: NavigationPath = .init()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 0) {
                HATitleTextView(text: "Settings", icon: "gear")
                    .padding()
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
                }
            }.navigationDestination(for: NavigationDestination.self) { option in
                option.view($path)
            }
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing:
                    Button(
                        "Dismiss",
                        action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    ).accentColor(ColorManager.haDefaultDark)
            )
            #endif
        }
        .background(Color(.systemGray))
    }
}

struct ModalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ModalSettingsView()
    }
}
