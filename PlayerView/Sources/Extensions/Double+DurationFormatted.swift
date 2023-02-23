import Foundation

extension Double {
    var durationFormatted: String {
        let formatter = DateComponentsFormatter()

        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad

        guard isFinite && !isNaN else {
            return ""
        }

        return formatter.string(from: self) ?? ""
    }
}
