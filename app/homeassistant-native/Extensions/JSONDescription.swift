import Foundation

extension Encodable {
    func jsonDescription() -> String {
        String(data: try! JSONEncoder().encode(self), encoding: .utf8) ?? ""
    }
}
