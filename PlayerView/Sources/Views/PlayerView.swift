import SwiftUI
import AVFoundation

struct UIPlayerView: UIViewRepresentable {
    var player: AVPlayer

    @Binding var videoGravity: AVLayerVideoGravity

    init(player: Player, videoGravity: Binding<AVLayerVideoGravity> = .constant(.resizeAspect)) {
        self.player = player.player
        _videoGravity = videoGravity
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
