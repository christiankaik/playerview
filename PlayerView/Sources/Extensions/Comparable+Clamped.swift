import Foundation

extension Comparable {
    func clamped(minimum: Self, maximum: Self) -> Self {
        min(max(minimum, self), maximum)
    }
}
