import AVFoundation
import Combine
import Foundation

extension PlayerController {
    enum Status: String {
        case preparing
        case ready
        case failed
    }
}

@MainActor final class PlayerController: ObservableObject {
    static let seekToleranceBefore: TimeInterval = 1 / 600
    static let seekToleranceAfter: TimeInterval = 1 / 600
    static let periodicUpdateInterval = CMTime(value: 1, timescale: 60)
    let avPlayer: AVPlayer
    @Published private(set) var status = Status.preparing
    @Published private(set) var error: Error?
    @Published private(set) var isPlaying = false
    @Published private(set) var isSeeking = false
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var currentTimeSeconds: TimeInterval = 0
    @Published private(set) var asset: AVAsset?
    var progress: Double {
        currentTimeSeconds / duration
    }
    var isScrubbingPublisher: AnyPublisher<Bool, Never> {
        isScrubbingSubject.eraseToAnyPublisher()
    }
    let isScrubbingSubject = CurrentValueSubject<Bool, Never>(false)
    private(set) var scrubberSeconds: TimeInterval?
    private var wasPlaying = false
    private var cancellables = Set<AnyCancellable>()

    convenience init(url: URL) {
        let player = AVPlayer()
        self.init(player: player)
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        self.asset = item.asset
    }

    private init(player: AVPlayer) {
        self.avPlayer = player
        bind()
    }

    deinit {
        avPlayer.replaceCurrentItem(with: nil)
    }

    private func bind() {
        avPlayer.publisher(for: \.currentItem)
            .receive(on: RunLoop.main)
            .map { $0?.asset }
            .sink { [weak self] asset in
                self?.asset = asset
            }
            .store(in: &cancellables)

        avPlayer.publisher(for: \.rate)
            .receive(on: RunLoop.main)
            .map { $0 != 0 }
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)

        avPlayer.publisher(for: \.currentItem?.duration)
            .compactMap { $0?.seconds }
            .sink {[weak self] in
                    self?.duration = $0
            }
            .store(in: &cancellables)
        avPlayer.addPeriodicTimeObserver(forInterval: Self.periodicUpdateInterval, queue: .main) { [weak self] time in
            self?.currentTimeSeconds = time.seconds
        }
        let playerItemStatusPublisher = avPlayer.publisher(for: \.currentItem?.status)
        let playerStatusPublisher = avPlayer.publisher(for: \.status)
        playerStatusPublisher.combineLatest(playerItemStatusPublisher) { playerStatus, itemStatus -> Status in
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
        .receive(on: RunLoop.main)
        .assign(to: \.status, on: self)
        .store(in: &cancellables)
        let playerItemErrorPublisher = avPlayer.publisher(for: \.currentItem?.error)
        let playerErrorPublisher = avPlayer.publisher(for: \.error)
        playerErrorPublisher.combineLatest(playerItemErrorPublisher) { playerError, itemError -> Error? in
            playerError ?? itemError ?? nil
        }
        .receive(on: RunLoop.main)
        .sink { [weak self] in
            self?.error = $0
        }
        .store(in: &cancellables)
    }
    private func timeInterval(for progress: Double) -> TimeInterval {
        return progress * duration
    }
    func time(forTimeInterval timeInterval: TimeInterval) -> CMTime {
        CMTime(seconds: timeInterval, preferredTimescale: 600)
    }
    private func startScrubbing(at fraction: Double? = nil) {
        if !isScrubbingSubject.value {
            isScrubbingSubject.value = true
            wasPlaying = isPlaying
            pause()
        }
        if let fraction {
            scrubberSeconds = timeInterval(for: fraction)
        }
    }

    private func finishScrubbing(at fraction: Double?) {
        scrubberSeconds = nil
        guard isScrubbingSubject.value else { return }

        isScrubbingSubject.send(false)
        defer {
            if wasPlaying {
                play()
            }
        }
        guard let fraction
        else { return }
        seek(toFraction: fraction)
    }
    func play() {
        avPlayer.play()
    }
    func pause() {
        avPlayer.pause()
    }
    func playPause() {
        if avPlayer.rate != 0 {
            avPlayer.pause()
        } else {
            avPlayer.play()
        }
    }
    func seek(to time: CMTime) {
        isSeeking = true
        let toleranceBefore = CMTime(seconds: Self.seekToleranceBefore, preferredTimescale: time.timescale)
        let toleranceAfter = CMTime(seconds: Self.seekToleranceAfter, preferredTimescale: time.timescale)
        avPlayer.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { [weak self] _ in
            self?.isSeeking = false
        }
    }
}

extension PlayerController {
    func seek(toSeconds seconds: TimeInterval) {
        guard let timescale = avPlayer.currentItem?.duration.timescale else {
            return
        }
        seek(to: CMTime(seconds: seconds, preferredTimescale: timescale))
    }
    func seek(toFraction fraction: Double) {
        guard let duration = avPlayer.currentItem?.duration.seconds else {
            return
        }
        seek(toSeconds: fraction * duration)
    }
    func seekForward(by seconds: TimeInterval) {
        guard let item = avPlayer.currentItem else {
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
    func seekBackward(by seconds: TimeInterval) {
        seekForward(by: -seconds)
    }
    func scrub(_ isScrubbing: Bool, to fraction: Double?) {
        if isScrubbing {
            startScrubbing(at: fraction)
        } else {
            finishScrubbing(at: fraction)
        }
    }
}
