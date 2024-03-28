import Foundation
import RealmSwift

public class OctopusRateModelObject: Object, ObjectKeyIdentifiable {
    @Persisted public var id = UUID().uuidString
    @Persisted public var start: Date
    @Persisted public var end: Date
    @Persisted public var price: Double
}
