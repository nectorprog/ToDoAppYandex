import Foundation

extension Date {
    var unixTimestamp: Int {
        return Int(self.timeIntervalSince1970)
    }

    static func from(unixTimestamp: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
    }
}
