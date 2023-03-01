import Foundation

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
