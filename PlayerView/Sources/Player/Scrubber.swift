import Foundation
import Combine

final class Scrubber {
    let player: Player

    var isScrubbing: AnyPublisher<Bool, Never> { isScrubbingSubject.eraseToAnyPublisher() }
    var time: AnyPublisher<TimeInterval?, Never> { timeSubject.eraseToAnyPublisher() }

    private let isScrubbingSubject = CurrentValueSubject<Bool, Never>(false)
    private let timeSubject = CurrentValueSubject<TimeInterval?, Never>(nil)

    private var duration: TimeInterval = 0
    private var isPlaying = false
    private var wasPlaying = false
    private var cancellables = Set<AnyCancellable>()

    init(player: Player) {
        self.player = player

        bind()
    }

    func scrub(_ isScrubbing: Bool, to fraction: Double?) {
        if isScrubbing {
            startScrubbing(at: fraction)
        } else {
            finishScrubbing(at: fraction)
        }
    }

    private func bind() {
        player.isPlaying
            .sink { [weak self] isPlaying in
                self?.isPlaying = isPlaying
            }
            .store(in: &cancellables)

        player.durationSeconds
            .compactMap { $0 }
            .sink { [weak self] duration in
                self?.duration = duration
            }
            .store(in: &cancellables)
    }

    private func timeInterval(for value: Double) -> TimeInterval {
        value * duration
    }

    private func startScrubbing(at value: Double? = nil) {
        if !isScrubbingSubject.value {
            isScrubbingSubject.send(true)
            wasPlaying = isPlaying

            player.pause()
        }

        if let value {
            timeSubject.send(timeInterval(for: value))
        }
    }

    private func finishScrubbing(at value: Double?) {
        timeSubject.send(nil)

        guard isScrubbingSubject.value else {
            return
        }

        isScrubbingSubject.send(false)

        defer {
            if wasPlaying {
                player.play()
            }
        }

        guard let value else {
            return
        }

        player.seek(to: timeInterval(for: value))
    }
}
