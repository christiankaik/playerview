import SwiftUI
import AVFoundation

struct PlaylistView: View {
    let player = AVPlayer()

    @StateObject private var viewModel = PlaylistViewModel()

    @State private var showPlayer = false
    @State private var item: PlaylistItem? = nil {
        didSet {
            if let item {
                player.replaceCurrentItem(with: AVPlayerItem(url: item.url))
            } else {
                player.replaceCurrentItem(with: nil)
            }
        }
    }

    var body: some View {
        NavigationView {
            List(viewModel.items) { item in
                Button {
                    self.item = item
                    showPlayer = true
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        if let title = item.title {
                            Text(title)
                        }

                        Text(item.url.absoluteString)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Streams")
        }
        .fullScreenCover(isPresented: $showPlayer) {
            item = nil
        } content: {
            CPlayerView(player: player, isPresented: $showPlayer)
        }
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView()
    }
}
