import Foundation
import Combine

private let defaultItems: [PlaylistItem] = [
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
        url: "https://google.com"
    ),
    PlaylistItem(
        title: "Sintel MP4",
        url: "http://www.peach.themazzone.com/durian/movies/sintel-1280-surround.mp4"
    )
]

final class PlaylistViewModel: ObservableObject {
    @Published var items: [PlaylistItem] = defaultItems
}
