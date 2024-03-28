import Foundation
import RealmSwift

public class OctopusRateModelObject: Object, ObjectKeyIdentifiable {
    @Persisted public var id: String
    @Persisted public var start: Date
    @Persisted public var end: Date
    @Persisted public var price: Double

    public convenience init(start: Date, end: Date, price: Double) {
        self.init()
        self.id = start.timeIntervalSinceReferenceDate.description
        self.start = start
        self.end = end
        self.price = price
    }

    public override class func primaryKey() -> String? {
        return "id"
    }
}
