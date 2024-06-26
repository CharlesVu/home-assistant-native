import Foundation

extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
    }

    func priceFormatted() -> String {
        return String(format: "%.2f", self)
    }
}
