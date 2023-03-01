import Foundation
import Combine
import AVFoundation
import UIKit

final class PreviewWindowViewModel: ObservableObject {
    let scrubber: Scrubber

    @Published private(set) var isScrubbing = false
    @Published private(set) var image: UIImage? = nil
    @Published private(set) var canShow = false

    var show: Bool { isScrubbing && canShow }

    private var imageGenerator: AVAssetImageGenerator? = nil
    private var maximumSize: CGSize
    private var cache = NSCache<NSValue, UIImage>()
    private var cancellables = Set<AnyCancellable>()

    init(scrubber: Scrubber, maximumWidth: CGFloat) {
        self.scrubber = scrubber
        maximumSize = CGSize(width: maximumWidth, height: 0)

        // TODO: properly configure NSCache instance.
        cache.countLimit = 20

        bind()
    }

    deinit {
        clearImageGenerator()
    }

    private func time(for seconds: TimeInterval) -> CMTime {
        CMTime(seconds: seconds, preferredTimescale: 600)
    }

    private func triggerLoad(at seconds: TimeInterval?) {
        guard let seconds else {
            return
        }

        Task {
            await load(at: time(for: seconds))
        }
    }

    private func load(at time: CMTime) async {
        guard canShow else {
            return
        }

        if let image = imageFromCache(at: time) {
            await setImage(image: image)
            return
        }

        guard let imageGenerator else {
            await setImage(image: nil)
            return
        }

        let cgImage: CGImage

        do {
            (cgImage, _) = try await imageGenerator.image(at: time)
        } catch {
            // No image was found, we ignore this and just show the last image
            return
        }

        let image = UIImage(cgImage: cgImage)
        cacheImage(image, at: time)

        await setImage(image: image)
    }

    @MainActor
    private func setImage(image: UIImage?) {
        self.image = image
    }

    private func clearImageGenerator() {
        imageGenerator?.cancelAllCGImageGeneration()
        imageGenerator = nil
    }

    private func makeImageGenerator(for asset: AVAsset?) -> AVAssetImageGenerator? {
        guard let asset = asset as? AVURLAsset else {
            return nil
        }

        imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator?.appliesPreferredTrackTransform = true
        imageGenerator?.maximumSize = maximumSize
        imageGenerator?.requestedTimeToleranceAfter = CMTime(seconds: 1, preferredTimescale: 600)
        imageGenerator?.requestedTimeToleranceBefore = CMTime(seconds: 1, preferredTimescale: 600)

        return imageGenerator
    }

    private func imageFromCache(at time: CMTime) -> UIImage? {
        cache.object(forKey: NSValue(time: time))
    }

    private func cacheImage(_ image: UIImage, at time: CMTime) {
        cache.setObject(image, forKey: NSValue(time: time))
    }

    private func setupImageGenerator(for asset: AVAsset?) {
        clearImageGenerator()

        canShow = false
        image = nil
        imageGenerator = makeImageGenerator(for: asset)

        verifyImageGeneration()
    }

    private func verifyImageGeneration() {
        Task {
            guard
                let imageGenerator,
                let _ = try? await imageGenerator.image(at: .zero)
            else {
                return
            }

            Task { @MainActor in
                canShow = true
            }
        }
    }

    private func bind() {
        scrubber.player.asset
            .receive(on: RunLoop.main)
            .map { $0?.asset }
            .sink { [weak self] asset in
                self?.setupImageGenerator(for: asset)
            }
            .store(in: &cancellables)

        scrubber.isScrubbing
            .receive(on: RunLoop.main)
            .sink { [weak self] isScrubbing in
                self?.isScrubbing = isScrubbing
            }
            .store(in: &cancellables)

        scrubber.time
            .throttle(for: 0.2, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] seconds in
                self?.triggerLoad(at: seconds)
            }
            .store(in: &cancellables)
    }
}
