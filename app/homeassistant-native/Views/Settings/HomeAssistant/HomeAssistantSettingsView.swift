import ApplicationConfiguration
import Combine
import Factory
import SwiftUI

class HomeAssistantSettingsViewModel: ObservableObject {
    @Injected(\.config) private var configurationPublisher
    @Injected(\.homeAssistantConfigurationManager) private var homeAssistantConfigurationManager

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

    init() {
        configurationPublisher
            .homeAssistantConfigurationPublisher
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
        homeAssistantConfigurationManager.set(
            websocketEndpoint: URL(string: websocketEndpoint)!,
            authToken: authToken
        )
        buttonTitle = "Saved"
    }
}

struct HomeAssistantSettingsView: View {
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
            .accentColor(ColorManager.haDefaultDark)
        }
        .navigationTitle("Home Assistant")
        .accentColor(ColorManager.haDefaultDark)
        .onAppear {
            viewModel.initializeValues()
        }
    }
}
