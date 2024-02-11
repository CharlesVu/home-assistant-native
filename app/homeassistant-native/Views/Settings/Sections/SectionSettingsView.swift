import ApplicationConfiguration
import Combine
import Factory
import SwiftUI
import RealmSwift

struct SectionsSettingsView: View {
    @ObservedResults(SectionModelObject.self) var sections
    
    var path: Binding<NavigationPath>

    var body: some View {
        List {
            ForEach(sections) { section in
                NavigationLink(
                    value: NavigationDestination.sectionDetailSettingsView(sectionInformation: section),
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
                    SectionDetailSettingsView(path: path, sectionInformation: nil)
                } label: {
                    Text("Add")
                }
                .accentColor(ColorManager.haDefaultDark)

        )
    }
}
