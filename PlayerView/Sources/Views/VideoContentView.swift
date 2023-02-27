import SwiftUI
import AVFoundation

struct VideoContentView: View {
    private let player: Player

    @Binding var videoGravity: AVLayerVideoGravity

    init(_ player: Player, videoGravity: Binding<AVLayerVideoGravity>) {
        self.player = player
        _videoGravity = videoGravity
    }

    var body: some View {
        UIPlayerView(player: player, videoGravity: _videoGravity)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                player.play()
            }
    }
}
