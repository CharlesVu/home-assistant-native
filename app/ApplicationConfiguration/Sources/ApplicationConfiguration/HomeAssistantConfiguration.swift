import Factory
import Foundation

public struct HomeAssistantConfiguration {
    public let websocketEndpoint: URL
    public let authToken: String
}

public class HomeAssistantConfigurationManager {
    @Injected(\.config) private var config

    var websocketEndpoint: URL!

    var authToken: String!

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

    public func set(websocketEndpoint: URL, authToken: String) {
        self.websocketEndpoint = websocketEndpoint
        self.authToken = authToken
        UserDefaults.standard.setValue(
            websocketEndpoint.absoluteString,
            forKey: "HomeAssistantConfiguration.websocketEndpoint"
        )
        UserDefaults.standard.setValue(authToken, forKey: "HomeAssistantConfiguration.authToken")
        sendUpdateIfNeeded()
    }
}
