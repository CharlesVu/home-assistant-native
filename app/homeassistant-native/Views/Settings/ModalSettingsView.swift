import ApplicationConfiguration
import SwiftUI

enum NavigationDestination: Hashable {
    case sectionsSettingsView
    case sectionDetailSettingsView(sectionInformation: SectionModelObject)
    //    case entityConfigurationSettingsView
    //    case entityConfigurationDetailSettingsView(entityConfiguration: EntityModelObject, sections: [SectionModelObject])

    @ViewBuilder func view(_ path: Binding<NavigationPath>) -> some View {
        switch self {
            case .sectionsSettingsView:
                SectionsSettingsView(path: path)
            case .sectionDetailSettingsView(let sectionInformation):
                SectionDetailSettingsView(path: path, sectionInformation: sectionInformation)
        //            case .entityConfigurationSettingsView:
        //                EntityConfigurationSettingsView(path: path)
        //            case .entityConfigurationDetailSettingsView(let entityConfiguration, let sections):
        //                EntityDetailConfigurationSettingsView(path: path, entityConfiguration: entityConfiguration, sections: sections)
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

                        //                        NavigationLink(value: NavigationDestination.entityConfigurationSettingsView) {
                        //                            HASettingItemView(
                        //                                text: "Entities",
                        //                                icon: "list.dash.header.rectangle",
                        //                                foregroundColor: .accentColor,
                        //                                backgroundColor: .white
                        //                            )
                        //                        }

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
