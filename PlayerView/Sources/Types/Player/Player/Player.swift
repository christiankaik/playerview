import Foundation
import Combine
import AVFoundation

final class Player {
    static let seekToleranceBefore: TimeInterval = 1 / 600
    static let seekToleranceAfter: TimeInterval = 1 / 600
    static let periodicUpdateInterval = CMTime(value: 1, timescale: 60)

    let player: AVPlayer

    // MARK: Publishers

    var status: AnyPublisher<Status, Never> { statusSubject.eraseToAnyPublisher() }
    var error: AnyPublisher<Error?, Never> { errorSubject.eraseToAnyPublisher() }
    var isSeeking: AnyPublisher<Bool, Never> { isSeekingSubject.eraseToAnyPublisher() }
    var isPlaying: AnyPublisher<Bool, Never> { isPlayingSubject.eraseToAnyPublisher() }

    var asset: AnyPublisher<Asset?, Never> {
        assetSubject.map { Asset($0) }
            .eraseToAnyPublisher()
    }

    var currentTimeSeconds: AnyPublisher<TimeInterval?, Never> {
        currentTimeSubject.map { $0?.seconds as TimeInterval? }
            .eraseToAnyPublisher()
    }

    var durationSeconds: AnyPublisher<TimeInterval?, Never> {
        durationSubject.map { $0?.seconds as TimeInterval? }
            .eraseToAnyPublisher()
    }

    // MARK: Subjects

    private let isPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    private let assetSubject = CurrentValueSubject<AVAsset?, Never>(nil)
    private let durationSubject = CurrentValueSubject<CMTime?, Never>(nil)
    private let currentTimeSubject = CurrentValueSubject<CMTime?, Never>(nil)
    private let errorSubject = CurrentValueSubject<Error?, Never>(nil)
    private let statusSubject = CurrentValueSubject<Status, Never>(.preparing)
    private let isSeekingSubject = CurrentValueSubject<Bool, Never>(false)

    private var cancellables = Set<AnyCancellable>()
    private var periodicObserver: Any?

    // MARK: Init

    init(player: AVPlayer) {
        self.player = player

        bind()
    }

    private func bind() {
        player
            .publisher(for: \.rate)
            .map { $0 != 0 }
            .sink { [weak self] in
                self?.isPlayingSubject.send($0)
            }
            .store(in: &cancellables)

        player
            .publisher(for: \.currentItem)
            .sink { [weak self] in
                self?.assetSubject.send($0?.asset)
            }
            .store(in: &cancellables)

        player
            .publisher(for: \.currentItem?.duration)
            .sink { [weak self] in
                self?.durationSubject.send($0)
            }
            .store(in: &cancellables)

        // Error Observation
        let playerItemErrorPublisher = player.publisher(for: \.currentItem?.error)
        let playerErrorPublisher = player.publisher(for: \.error)

        playerErrorPublisher
            .combineLatest(playerItemErrorPublisher) { $0 ?? $1 ?? nil }
            .sink { [weak self] in
                self?.errorSubject.send($0)
            }
            .store(in: &cancellables)

        // Status Observation
        let playerItemStatusPublisher = player.publisher(for: \.currentItem?.status)
        let playerStatusPublisher = player.publisher(for: \.status)

        playerStatusPublisher
            .combineLatest(playerItemStatusPublisher) { playerStatus, itemStatus -> Status in
                if playerStatus == .failed {
                    return .failed
                }
                guard let itemStatus else {
                    return .preparing
                }
                if playerStatus == .unknown || itemStatus == .unknown {
                    return .preparing
                }
                if playerStatus == .failed || itemStatus == .failed {
                    return .failed
                }
                return .ready
            }
            .sink { [weak self] in
                self?.statusSubject.send($0)
            }
            .store(in: &cancellables)

        // Periodic Updates
        periodicObserver = player.addPeriodicTimeObserver(
            forInterval: Self.periodicUpdateInterval,
            queue: nil // should we do this on .main?
        ) { [weak self] time in
            self?.currentTimeSubject.send(time)
        }
    }
}

// MARK: Public Interface

extension Player {
    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func playPause() {
        if isPlayingSubject.value {
            pause()
        } else {
            play()
        }
    }

    func seek(to time: CMTime) {
        isSeekingSubject.send(true)

        let toleranceBefore = CMTime(seconds: Self.seekToleranceBefore, preferredTimescale: time.timescale)
        let toleranceAfter = CMTime(seconds: Self.seekToleranceAfter, preferredTimescale: time.timescale)

        player.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { [weak self] _ in
            self?.isSeekingSubject.send(false)
        }
    }

    func seekOffset(by seconds: TimeInterval) {
        guard let item = player.currentItem else {
            return
        }

        let duration = item.duration
        let offset = CMTime(seconds: seconds, preferredTimescale: item.duration.timescale)
        let target = item.currentTime() + offset

        if target > duration {
            seek(to: duration)
        } else if target < .zero {
            seek(to: .zero)
        } else {
            seek(to: target)
        }
    }
}

// MARK: Convenience Methods

extension Player {
    func skipForward(by seconds: TimeInterval) {
        seekOffset(by: abs(seconds))
    }

    func skipBackward(by seconds: TimeInterval) {
        seekOffset(by: -abs(seconds))
    }
}
