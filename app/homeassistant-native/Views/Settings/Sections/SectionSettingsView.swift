import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

struct SectionsSettingsView: View {
    @ObservedResults(DisplayableModelObject.self) var sections

    var path: Binding<NavigationPath>

    var body: some View {
        List {
            ForEach(sections) { section in
                NavigationLink(
                    value: NavigationDestination.vStackConfiguration(sectionInformation: section),
                    label: {
                        Text(section.name)
                    }
                )
            }
            .accentColor(ColorManager.haDefaultDark)

        }
        .navigationBarItems(
            trailing:
                NavigationLink {
                    VStackConfigurationView(path: path, sectionInformation: nil)
                } label: {
                    Text("Add")
                }
                .accentColor(ColorManager.haDefaultDark)

        )
    }
}
