import Factory
import Foundation

public struct HomeAssistantConfiguration {
    public let websocketEndpoint: URL
    public let authToken: String
}

public class HomeAssistantConfigurationManager {
    @Injected(\.config) private var config

    public var websocketEndpoint: URL! {
        didSet {
            UserDefaults.standard.setValue(websocketEndpoint, forKey: "HomeAssistantConfiguration.websocketEndpoint")
            sendUpdateIfNeeded()
        }
    }

    public var authToken: String! {
        didSet {
            UserDefaults.standard.setValue(authToken, forKey: "HomeAssistantConfiguration.authToken")
            sendUpdateIfNeeded()
        }
    }

    public init() {
        websocketEndpoint = URL(
            string: UserDefaults.standard.string(forKey: "HomeAssistantConfiguration.websocketEndpoint")!
        )!
        authToken = UserDefaults.standard.string(forKey: "HomeAssistantConfiguration.authToken")
        sendUpdateIfNeeded()
    }

    private func sendUpdateIfNeeded() {
        if websocketEndpoint != nil && authToken != nil {
            config.homeAssistantConfigurationPublisher.send(
                .init(websocketEndpoint: websocketEndpoint, authToken: authToken)
            )
        }
    }
}
