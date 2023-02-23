import Foundation

extension Date {
    var durationFormatted: String {
        let formatter = DateFormatter()

        formatter.dateFormat = "HH:mm"

        return formatter.string(from: self)
    }
}
