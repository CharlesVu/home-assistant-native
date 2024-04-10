import ApplicationConfiguration
import Foundation

public protocol EntityAttachable: Hashable {
    var entityID: String? { get set }
}

extension ButtonConfiguration: EntityAttachable {}
