import SwiftUI
import AVFoundation

private struct PlaylistItem: Identifiable {
    let id = UUID()
    let title: String
    let url: URL

    init(title: String, url: String) {
        self.title = title
        self.url = URL(string: url)!
    }
}

private let playlist: [PlaylistItem] = [
    PlaylistItem(
        title: "Apple HLS Sample",
        url: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8"
    ),
    PlaylistItem(
        title: "Some other HLS",
        url: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s-fmp4/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"
    ),
    PlaylistItem(
        title: "Invalid",
        url: "https://file-examples.com/storage/fe1aa0c9d563ea1e4a1fd34/2017/04/file_example_MP4_1920_18MG.mp4"
    ),
]

struct PlaylistView: View {
    let player = AVPlayer()

    @State private var item: PlaylistItem? = nil {
        didSet {
            if let item {
                player.replaceCurrentItem(with: AVPlayerItem(url: item.url))
            } else {
                player.replaceCurrentItem(with: nil)
            }
        }
    }

    @State private var showPlayer = false

    var body: some View {
        NavigationView {
            List(playlist) { item in
                Button {
                    self.item = item
                    showPlayer = true
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)

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
