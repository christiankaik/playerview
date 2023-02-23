import AVFoundation
import SwiftUI

struct CPlayerView: View {
    @StateObject private var player = PlayerController(url: streamUrl)
    private let preview = AssetImageLoader(asset: nil, maximumWidth: 150)
    @State private var showControls: Bool = true

    var body: some View {
        ZStack {
            VideoContentView(player) {
                withAnimation(.spring()) {
                    showControls.toggle()
                }
            }
            PlayerControlsView(player: player, showControls: $showControls)
            PreviewWindowView(player: player)
        }
        .persistentSystemOverlays(.hidden)
        .background(.black)
    }
}

struct CPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        CPlayerView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
