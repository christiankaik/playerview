import SwiftUI

struct VideoContentView: View {
    private let player: Player

    init(_ player: Player) {
        self.player = player
    }

    var body: some View {
        UIPlayerView(player: player)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                player.play()
            }
    }
}
