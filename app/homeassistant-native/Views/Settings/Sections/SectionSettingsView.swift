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
    @State private var path: [SectionInformation] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(viewModel.sections) { section in
                    NavigationLink(value: section, label: {
                        Text(section.name)
                    }).navigationDestination(for: SectionInformation.self) { section in
                        SectionDetailSettingsView(path: $path, sectionInformation: section)
                    }
                }
                .accentColor(ColorManager.haDefaultDark)

            }
        }            
        .navigationBarItems(
            trailing:
                NavigationLink {
                    SectionDetailSettingsView(path: $path, sectionInformation: nil)
                } label: {
                    Text("Add")
                }
                .accentColor(ColorManager.haDefaultDark)

        )
    }
}
