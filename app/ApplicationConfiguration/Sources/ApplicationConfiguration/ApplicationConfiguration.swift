import Combine
import Foundation

public struct ApplicationConfiguration {
    public let homeAssistantConfigurationPublisher = CurrentValueSubject<HomeAssistantConfiguration?, Never>(nil)

    public let sectionPublisher = CurrentValueSubject<[SectionInformation], Never>([])
    public let entityConfigurationPublisher = CurrentValueSubject<[EntityConfiguration], Never>([])

}
