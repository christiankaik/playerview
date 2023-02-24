import AVFoundation
import SwiftUI

struct CPlayerView: View {
    static let previewFrameWidth: CGFloat = 150

    private let scrubber: Scrubber
    private let player: Player

    @State private var showControls: Bool = true
    @State private var scrubberFrame: CGRect? = nil
    @State private var offsetX: CGFloat = 50

    init(player: AVPlayer) {
        self.player = Player(player: player)
        self.scrubber = Scrubber(player: self.player)
    }

    var body: some View {
        ZStack {
            VideoContentView(scrubber.player)
                .onTapGesture {
                    withAnimation(.spring()) {
                        showControls.toggle()
                    }
                }

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
            .padding()
        }
        .persistentSystemOverlays(.hidden)
        .background(.black)
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

struct CPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        CPlayerView(player: AVPlayer(url: streamUrl))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
