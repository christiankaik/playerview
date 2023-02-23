import SwiftUI
import Foundation
import Combine

extension View {
    public func onChange<Value>(
        of value: Value,
        throttleInterval: TimeInterval,
        perform action: @escaping (_ newValue: Value) -> Void
    ) -> some View where Value: Equatable {
        self.modifier(ThrottledChangeViewModifier(trigger: value, interval: throttleInterval, action: action))
    }
}

private struct ThrottledChangeViewModifier<Value>: ViewModifier where Value: Equatable {
    let trigger: Value
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let action: (Value) -> Void

    @State private var task: Task<Void, Never>?
    @State private var currentValue: Value?

    init(trigger: Value, interval: TimeInterval, action: @escaping (Value) -> Void) {
        self.trigger = trigger
        self.timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
        self.action = action
    }

    func body(content: Content) -> some View {
        content
        .onReceive(timer) { _ in
            guard let currentValue else {
                return
            }

            action(currentValue)
        }
        .onChange(of: trigger) { value in
            currentValue = value
        }
    }
}
