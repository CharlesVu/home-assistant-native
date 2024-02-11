import ApplicationConfiguration
import Combine
import Factory
import SwiftUI

class SectionDetailSettingsViewModel: ObservableObject {
    @Injected(\.databaseManager) var databaseManager
    @Published var sectionInformation: SectionModelObject

    @Published var name: String {
        didSet {
            validateInput()
        }
    }
    @Published var parentSection: String {
        didSet {
            validateInput()
        }
    }

    @Published var buttonTitle = "Save"
    @Published var isValid = false
    var path: Binding<NavigationPath>

    init(sectionInformation: SectionModelObject?, path: Binding<NavigationPath>) {
        if let sectionInformation {
            self.sectionInformation = sectionInformation.thaw()!
            self.name = sectionInformation.name
            self.parentSection = sectionInformation.parentSection
            
        } else {
            self.sectionInformation = .init()
            self.name = ""
            self.parentSection = ""
        }
        self.path = path
    }

    func validateInput() {
        isValid = name != "" && parentSection != ""
    }

    @MainActor
    func save() async {
        do {
            try databaseManager.database().write {
                sectionInformation.name = name
                sectionInformation.parentSection = parentSection
                databaseManager.database().add(sectionInformation, update: .modified)
            }
            path.wrappedValue.removeLast()
        } catch {
            buttonTitle = "The Dev fucked up"
        }
    }
}

struct SectionDetailSettingsView: View {
    @ObservedObject var viewModel: SectionDetailSettingsViewModel

    init(path: Binding<NavigationPath>, sectionInformation: SectionModelObject?) {
        viewModel = .init(sectionInformation: sectionInformation, path: path)
    }

    var body: some View {
        Form {
            Section("Section Name") {
                TextField("Name", text: $viewModel.name)
            }
            Section("Column") {
                TextField("1", text: $viewModel.parentSection)
            }
            Button(viewModel.buttonTitle) {
                Task {
                    await viewModel.save()
                }
            }
            .disabled(!viewModel.isValid)
            .transition(.opacity)
            .accentColor(ColorManager.haDefaultDark)
        }
        .navigationTitle("Section")
        .accentColor(ColorManager.haDefaultDark)
    }
}
