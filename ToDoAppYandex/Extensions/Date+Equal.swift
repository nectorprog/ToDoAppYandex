import Foundation

extension Date {
    func isEqualRounded(to otherDate: Date?, precision: Double) -> Bool {
        guard let otherDate = otherDate else { return false }
        return abs(self.timeIntervalSince(otherDate)) < precision
    }
}
