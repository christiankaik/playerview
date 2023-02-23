import Foundation
import AVFoundation
import UIKit

final class AssetImageLoader: ObservableObject {
	var asset: AVURLAsset? {
		get {
			imageGenerator?.asset as? AVURLAsset
		}

		set {
			imageGenerator = makeImageGenerator(for: newValue)
		}
	}

    @Published var image: UIImage?
    @Published var isLoading: Bool = false

	private var imageGenerator: AVAssetImageGenerator?
	private var maximumSize: CGSize
	private var cache: [CMTime: UIImage] = [:]

	init(asset: AVAsset?, maximumSize: CGSize) {
		self.imageGenerator = nil
		self.maximumSize = maximumSize

		imageGenerator = makeImageGenerator(for: asset)
	}

	convenience init(asset: AVAsset?, maximumWidth: CGFloat) {
		self.init(asset: asset, maximumSize: CGSize(width: maximumWidth, height: 0))
	}

	convenience init(asset: AVAsset?, maximumHeight: CGFloat) {
		self.init(asset: asset, maximumSize: CGSize(width: 0, height: maximumHeight))
	}

	deinit {
		clear()
	}

	func clear() {
		imageGenerator?.cancelAllCGImageGeneration()
		imageGenerator = nil
		cache = [:]
	}

	func load(at time: CMTime) async {
        await setIsLoading(true)

		if let image = cache[time] {
			await setImage(image: image)
            await setIsLoading(false)
			return
		}

		guard let imageGenerator else {
            await setImage(image: nil)
            await setIsLoading(false)
			return
		}

		let cgImage: CGImage

		do {
            (cgImage, _) = try await imageGenerator.image(at: time)
		} catch {
            await setImage(image: nil)
            await setIsLoading(false)
			return
		}

		let image = UIImage(cgImage: cgImage)
		cache[time] = image

		await setImage(image: image)
        await setIsLoading(false)
	}

	@MainActor
    private func setImage(image: UIImage?) {
		self.image = image
	}

    @MainActor
    private func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }

	private func makeImageGenerator(for asset: AVAsset?) -> AVAssetImageGenerator? {
		clear()

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
}
