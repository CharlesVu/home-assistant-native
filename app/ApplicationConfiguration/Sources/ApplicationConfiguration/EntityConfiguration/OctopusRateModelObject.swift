import Foundation
import RealmSwift

public class OctopusRateModelObject: Object {
    @Persisted public var start: Date
    @Persisted public var end: Date
    @Persisted public var price: Double
}
