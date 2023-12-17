import ApplicationConfiguration
import Combine
import Factory
import SwiftUI

class SectionsSettingsViewModel: ObservableObject {
    @Injected(\.config) private var configurationPublisher

    @Published var sections: [SectionInformation] = []

    private var subscriptions = Set<AnyCancellable>()

    init() {
        configurationPublisher
            .sectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                self?.sections = sections
            }
            .store(in: &subscriptions)
    }
}

struct SectionsSettingsView: View {
    @ObservedObject var viewModel: SectionsSettingsViewModel = .init()

    var body: some View {
        List {
            ForEach(viewModel.sections) { section in
                NavigationLink {
                    SectionDetailSettingsView(sectionInformation: section)
                } label: {
                    Text(section.name)
                }
            }
            .accentColor(ColorManager.haDefaultDark)
        }
        .navigationBarItems(
            trailing:
                NavigationLink {
                    SectionDetailSettingsView(sectionInformation: nil)
                } label: {
                    Text("Add")
                }
                .accentColor(ColorManager.haDefaultDark)

        )

    }
}
