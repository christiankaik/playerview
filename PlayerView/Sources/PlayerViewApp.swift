import SwiftUI
import AVKit

@main
struct PlayerViewApp: App {
    var body: some Scene {
        WindowGroup {
			CPlayerView(player: AVPlayer(url: streamUrl))
            // VideoPlayer(player: AVPlayer(url: streamUrl))
        }
    }
}
