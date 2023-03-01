import SwiftUI

struct PlayerBottomControlsView: View {
    static let previewFrameWidth: CGFloat = 150

    let scrubber: Scrubber
    let onInteract: () -> Void

    @State private var scrubberFrame: CGRect? = nil
    @State private var offsetX: CGFloat = 0

    init(scrubber: Scrubber, onInteract: @escaping (() -> Void)) {
        self.scrubber = scrubber
        self.onInteract = onInteract
    }

    var body: some View {
        VStack(alignment: .leading) {
            PreviewWindowView(scrubber: scrubber, width: Self.previewFrameWidth)
                .offset(x: offsetX)

            PlayerControls(scrubber: scrubber, onInteract: onInteract)
        }
        .coordinateSpace(.playerControls)
        .onPreferenceChange(ScrubberFrameKey.self) { frame in
            scrubberFrame = frame
        }
        .onReceive(scrubber.progress) { progress in
            updatePreviewOffset(progress)
        }
    }

    private func updatePreviewOffset(_ progress: Double) {
        guard let scrubberFrame else {
            return
        }

        let offsetX = scrubberFrame.minX + (progress * scrubberFrame.width) - (Self.previewFrameWidth / 2)

        self.offsetX = offsetX.clamped(
            minimum: scrubberFrame.minX,
            maximum: scrubberFrame.maxX - Self.previewFrameWidth
        )
    }
}
