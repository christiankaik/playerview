import Foundation
import SwiftUI

struct PlayerOverlayView: View {
    static let previewFrameWidth: CGFloat = 150

    private let scrubber: Scrubber

    @Binding var showControls: Bool
    @State private var scrubberFrame: CGRect?
    @State private var offsetX: CGFloat

    init(scrubber: Scrubber, showControls: Binding<Bool>) {
        self.scrubber = scrubber
        _showControls = showControls
        self.scrubberFrame = nil
        self.offsetX = 0
    }

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()

            PreviewWindowView(scrubber: scrubber, width: Self.previewFrameWidth)
                .offset(x: offsetX)

            PlayerControlsView(scrubber: scrubber, showControls: $showControls)
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
