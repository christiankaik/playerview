import Foundation

extension Comparable {
    func clamped(minimum: Self, maximum: Self) -> Self {
        min(max(minimum, self), maximum)
    }
}

extension CaseIterable where Self: Equatable {
    // swiftlint:disable force_unwrapping
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}
