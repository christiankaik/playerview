import AVFoundation
import SwiftUI

struct CPlayerView: View {
    private let scrubber: Scrubber
    private let player: Player

    @State private var showControls: Bool = true

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
            PlayerControlsView(scrubber: scrubber, showControls: $showControls)
            PreviewWindowView(scrubber: scrubber)
        }
        .persistentSystemOverlays(.hidden)
        .background(.black)
    }
}

struct CPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        CPlayerView(player: AVPlayer(url: streamUrl))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
