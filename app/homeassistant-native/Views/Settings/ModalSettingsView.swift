import ApplicationConfiguration
import SwiftUI

enum NavigationDestination: Hashable {
    case sectionsSettingsView
    case sectionDetailSettingsView(sectionInformation: SectionModelObject)
    case addWidget(parent: SectionModelObject)

    @ViewBuilder func view(_ path: Binding<NavigationPath>) -> some View {
        switch self {
            case .sectionsSettingsView:
                SectionsSettingsView(path: path)
            case .sectionDetailSettingsView(let sectionInformation):
                VStackConfigurationView(path: path, sectionInformation: sectionInformation)
            case .addWidget(let parent):
                AddWidgetView(path: path, parent: parent)
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
                        .navigationDestination(for: NavigationDestination.self) { option in
                            option.view($path)
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
