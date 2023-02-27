import Foundation
import Combine

struct ErrorInfo: LocalizedError {
    var errorDescription: String?
    var failureReason: String?
    var recoverySuggestion: String?
    var helpAnchor: String?

    init?(error: Error?) {
        guard let error = error as? NSError else {
            return nil
        }

        errorDescription = error.localizedDescription
        failureReason = error.localizedFailureReason
        recoverySuggestion = error.localizedRecoverySuggestion
        helpAnchor = error.helpAnchor
    }
}

final class CPlayerViewModel: ObservableObject {
    let player: Player

    @Published var isError: Bool = false
    @Published var error: ErrorInfo?

    private var errorCancellable: AnyCancellable?

    init(player: Player) {
        self.player = player

        bind()
    }

    private func bind() {
        errorCancellable = player.error
            .receive(on: RunLoop.main)
            .map { ErrorInfo(error: $0) }
            .sink { [weak self] info in
                self?.error = info
                self?.isError = info != nil
            }
    }
}
