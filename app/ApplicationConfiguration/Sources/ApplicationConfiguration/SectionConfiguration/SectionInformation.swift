import Foundation
import RealmSwift

public class SectionInformation: Identifiable, Hashable, Equatable {
    public var id: String = UUID().uuidString
    public var name: String
    public var parentSection: String

    init(model: SectionModelObject) {
        id = model.id
        name = model.name
        parentSection = String(model.parentSection)
    }

    public init() {
        self.name = ""
        self.parentSection = "1"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: SectionInformation, rhs: SectionInformation) -> Bool {
        lhs.id == rhs.id
    }
}

class SectionModelObject: Object {
    @Persisted var id: String = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var parentSection: Int = 0

    public override class func primaryKey() -> String? {
        return "id"
    }

    convenience init(model: SectionInformation) {
        self.init()
        id = model.id
        name = model.name
        parentSection = Int(model.parentSection)!
    }
}
