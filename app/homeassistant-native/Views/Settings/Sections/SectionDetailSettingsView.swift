import ApplicationConfiguration
import Combine
import Factory
import SwiftUI

class SectionDetailSettingsViewModel: ObservableObject {
    @Injected(\.sectionManager) private var sectionManager

    @Published var sectionInformation: SectionInformation

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

    init(sectionInformation: SectionInformation?, path: Binding<NavigationPath>) {
        if let sectionInformation {
            self.sectionInformation = sectionInformation
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
            sectionInformation.name = name
            sectionInformation.parentSection = parentSection
            try await sectionManager.addSection(sectionInformation)
            path.wrappedValue.removeLast()
        } catch {
            buttonTitle = "The Dev fucked up"
        }
    }
}

struct SectionDetailSettingsView: View {
    @ObservedObject var viewModel: SectionDetailSettingsViewModel

    init(path: Binding<NavigationPath>, sectionInformation: SectionInformation?) {
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
