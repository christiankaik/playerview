import SwiftUI
import AVKit

@main
struct PlayerViewApp: App {
    var body: some Scene {
        WindowGroup {
			CPlayerView()
            // VideoPlayer(player: AVPlayer(url: streamUrl))
        }
    }
}
