import Foundation
import Combine

private enum DurationDisplayMode: CaseIterable {
    case differenceToCurrentTime
    case duration
    case endDateTime
}

final class PlayerControlsModel: ObservableObject {
    let scrubber: Scrubber
    var player: Player { scrubber.player }

    @Published private(set) var time: String = ""
    @Published private(set) var endTime: String = ""
    @Published private(set) var isSeeking = false
    @Published private(set) var isPlaying = false
    @Published private(set) var progress: Double = 0

    private var durationMode: DurationDisplayMode = .differenceToCurrentTime
    private var isScrubbing = false

    private var timeSeconds: TimeInterval? = nil
    private var scrubberTimeSeconds: TimeInterval? = nil
    private var durationSeconds: TimeInterval? = nil

    private var cancellables = Set<AnyCancellable>()

    init(scrubber: Scrubber) {
        self.scrubber = scrubber

        bind()
    }

    @MainActor
    func cycleDurationMode() {
        durationMode = durationMode.next()

        refreshEndTime()
    }

    private func bind() {
        player.isSeeking
            .receive(on: RunLoop.main)
            .sink { [weak self] isSeeking in
                self?.isSeeking = isSeeking
            }
            .store(in: &cancellables)

        player.isPlaying
            .receive(on: RunLoop.main)
            .sink { [weak self] isPlaying in
                self?.isPlaying = isPlaying
            }
            .store(in: &cancellables)

        let isScrubbingPublisher = scrubber.isScrubbing
        let scrubberTime = scrubber.time
        let currentTime = player.time

        currentTime
            .combineLatest(isScrubbingPublisher, scrubberTime)
            .receive(on: RunLoop.main)
            .sink { [weak self] (time, isScrubbing, scrubberTime) in
                self?.timeSeconds = time
                self?.isScrubbing = isScrubbing
                self?.scrubberTimeSeconds = scrubberTime

                self?.refreshTime()
            }
            .store(in: &cancellables)

        player.durationSeconds
            .receive(on: RunLoop.main)
            .sink { [weak self] duration in
                self?.durationSeconds = duration

                self?.refreshEndTime()
            }
            .store(in: &cancellables)

        player.time
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] time in
                guard let duration = self?.durationSeconds else {
                    return
                }

                self?.progress = time / duration
                self?.refreshEndTime()
            }
            .store(in: &cancellables)
    }

    private func refreshTime() {
        if let scrubberTimeSeconds, isScrubbing {
            time = scrubberTimeSeconds.durationFormatted
        } else {
            time = (timeSeconds ?? 0).durationFormatted
        }
    }

    private func refreshEndTime() {
        if let durationSeconds, let timeSeconds, !durationSeconds.isNaN, !timeSeconds.isNaN {
            switch durationMode {
            case .differenceToCurrentTime:
                endTime = "-\((durationSeconds - timeSeconds).durationFormatted)"
            case .duration:
                endTime = durationSeconds.durationFormatted
            case .endDateTime:
                let toEndTimeInterval = durationSeconds - timeSeconds

                endTime = Date()
                    .addingTimeInterval(toEndTimeInterval)
                    .durationFormatted
            }
        } else {
            endTime = "0:00"
        }
    }
}
