import SwiftUI
import AVFoundation

struct UIPlayerView: UIViewRepresentable {
    var player: AVPlayer

    init(player: PlayerController) {
        self.player = player.avPlayer
    }
    func makeUIView(context _: Context) -> AVPlayerView {
        let avPlayerView = AVPlayerView()
        avPlayerView.player = player
        return avPlayerView
    }
    func updateUIView(_: AVPlayerView, context _: Context) {}
}
