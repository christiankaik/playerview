import SwiftUI
import AVFoundation

struct VideoContentView: View {
    private let player: Player

    @Binding var videoGravityResizeAspect: Bool

    init(_ player: Player, videoGravityResizeAspect: Binding<Bool>) {
        self.player = player
        _videoGravityResizeAspect = videoGravityResizeAspect
    }

    var body: some View {
        UIPlayerView(player: player, videoGravityResizeAspect: _videoGravityResizeAspect)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                player.play()
            }
    }
}
