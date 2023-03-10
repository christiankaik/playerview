import Foundation
import Combine

final class PlayerOverlayViewModel: ObservableObject {
    let scrubber: Scrubber

    @Published private(set) var showControls = true

    private var isPlaying = false
    private var idleTimer: Timer?
    private var isPlayingCancellable: AnyCancellable?

    init(scrubber: Scrubber) {
        self.scrubber = scrubber

        bind()
    }

    private func bind() {
        isPlayingCancellable = scrubber.player.isPlaying
            .receive(on: RunLoop.main)
            .sink { [weak self] isPlaying in
                self?.isPlaying = isPlaying

                if isPlaying {
                    self?.refreshIdleTimer()
                } else {
                    self?.cancelIdleTimer()
                }
            }
    }

    func refreshIdleTimerIfPlaying() {
        guard isPlaying else {
            return
        }

        refreshIdleTimer()
    }

    private func refreshIdleTimer() {
        cancelIdleTimer()
        setupIdleTimer()
    }

    private func cancelIdleTimer() {
        idleTimer?.invalidate()
    }

    private func setupIdleTimer() {
        idleTimer = Timer.scheduledTimer(
            withTimeInterval: 3,
            repeats: false,
            block: timerFired
        )
    }

    private func timerFired(_: Timer) {
        Task { @MainActor [weak self] in
            self?.showControls = false
        }
    }
}
