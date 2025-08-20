import Combine
import Foundation

public struct HomeAssistantConfiguration {
    public let websocketEndpoint: URL
    public let authToken: String
}

public class HomeAssistantConfigurationManager: ObservableObject {
    private let homeAssistantConfigurationPublisher = CurrentValueSubject<HomeAssistantConfiguration?, Never>(nil)

    private var websocketEndpoint: URL!
    private var authToken: String!

    public init() {
        if let savedEnpoint = UserDefaults.standard.string(
            forKey: "HomeAssistantConfiguration.websocketEndpoint"
        ),
            let url = URL(string: savedEnpoint)
        {
            websocketEndpoint = url
        }

        authToken = UserDefaults.standard.string(forKey: "HomeAssistantConfiguration.authToken")
        sendUpdateIfNeeded()
    }

    private func sendUpdateIfNeeded() {
        if websocketEndpoint != nil && authToken != nil {
            homeAssistantConfigurationPublisher.send(
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

    public func listen() -> AnyPublisher<HomeAssistantConfiguration?, Never> {
        homeAssistantConfigurationPublisher.eraseToAnyPublisher()
    }
}
