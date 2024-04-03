import Combine
import Foundation

public struct ApplicationConfiguration {
    public let homeAssistantConfigurationPublisher = CurrentValueSubject<
        HomeAssistantConfiguration?, Never
    >(nil)
}
