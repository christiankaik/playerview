import Foundation
import SwiftUI

extension View {
    func simpleAlert<E: LocalizedError>(isPresented: Binding<Bool>, error: E?, onDismiss: (() -> Void)?) -> some View {
        self.alert(isPresented: isPresented, error: error) { _ in
            Button("Too Bad 😕") {
                onDismiss?()
            }
        } message: { error in
            if let failureReason = error.failureReason {
                Text(failureReason)
            } else {
                Text("Something went wrong")
            }
        }
    }
}
