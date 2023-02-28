import SwiftUI
import AVFoundation

struct UIPlayerView: UIViewRepresentable {
    var player: AVPlayer

    @Binding var videoGravityResizeAspect: Bool

    private var videoGravity: AVLayerVideoGravity {
        videoGravityResizeAspect ? .resizeAspect : .resizeAspectFill
    }

    init(player: Player, videoGravityResizeAspect: Binding<Bool> = .constant(true)) {
        self.player = player.player
        _videoGravityResizeAspect = videoGravityResizeAspect
    }
    
    func makeUIView(context _: Context) -> AVPlayerView {
        let avPlayerView = AVPlayerView()
        avPlayerView.player = player
        avPlayerView.playerLayer.videoGravity = videoGravity

        return avPlayerView
    }

    func updateUIView(_ avPlayerView: AVPlayerView, context _: Context) {
        avPlayerView.playerLayer.videoGravity = videoGravity
    }
}
