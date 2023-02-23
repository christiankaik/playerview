import SwiftUI

struct VideoContentView: View {
    private let player: PlayerController
    private let touchAction: () -> Void

    init(_ player: PlayerController, _ touchAction: @escaping () -> Void) {
        self.player = player
        self.touchAction = touchAction
    }

    var body: some View {
        UIPlayerView(player: player)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture { touchAction() }
            .onAppear {
                player.play()
            }
    }
}
