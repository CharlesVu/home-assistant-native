import ApplicationConfiguration
import Combine
import SwiftUI

class HomeAssistantSettingsViewModel: ObservableObject {
    @Published var websocketEndpoint: String = "wss://homeassistant.local/api/websocket" {
        didSet {
            validate()
        }
    }
    @Published var authToken: String = "My API Key" {
        didSet {
            validate()
        }
    }

    @Published var isValid = false
    @Published var buttonTitle = "Save"

    private var subscriptions = Set<AnyCancellable>()
    private var configuration: HomeAssistantConfiguration?
    private var homeAssistantConfigurationManager: HomeAssistantConfigurationManager?

    func set(homeAssistantConfigurationManager: HomeAssistantConfigurationManager) {
        self.homeAssistantConfigurationManager = homeAssistantConfigurationManager

        homeAssistantConfigurationManager.listen()
            .sink { [self] configuration in
                if let configuration {
                    self.configuration = configuration
                    self.websocketEndpoint = configuration.websocketEndpoint.absoluteString
                    self.authToken = configuration.authToken
                }
            }
            .store(in: &subscriptions)
    }

    func initializeValues() {
        if let configuration {
            websocketEndpoint = configuration.websocketEndpoint.absoluteString
            authToken = configuration.authToken
        }
    }

    func validate() {
        if let _ = URL(string: websocketEndpoint), authToken != "" {
            buttonTitle = "Save"
            isValid = true
            return
        }
        isValid = false
    }

    func save() {
        homeAssistantConfigurationManager?.set(
            websocketEndpoint: URL(string: websocketEndpoint)!,
            authToken: authToken
        )
        buttonTitle = "Saved"
    }
}

struct HomeAssistantSettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var homeAssistantConfigurationManager: HomeAssistantConfigurationManager
    @ObservedObject var viewModel: HomeAssistantSettingsViewModel = .init()

    var body: some View {
        Form {
            Section("Websocket URL") {
                TextField("wss://homeassistant.local/api/websocket", text: $viewModel.websocketEndpoint)
            }
            Section("My API Key") {
                SecureField("Auth Token", text: $viewModel.authToken)
            }
            Button(viewModel.buttonTitle) {
                viewModel.save()
            }
            .disabled(!viewModel.isValid)
            .transition(.opacity)
            .accentColor(themeManager.current.text)
        }
        .navigationTitle("Home Assistant")
        .accentColor(themeManager.current.text)
        .onAppear {
            viewModel.set(homeAssistantConfigurationManager: homeAssistantConfigurationManager)
            viewModel.initializeValues()
        }
    }
}
