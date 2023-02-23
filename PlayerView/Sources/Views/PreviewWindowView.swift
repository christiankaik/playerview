import AVFoundation
import SwiftUI

struct PreviewWindowView: View {
    @ObservedObject var player: PlayerController
    @State private var asset: AVAsset?
    @State private var preview = AssetImageLoader(asset: nil, maximumWidth: 150)
    @State private var isScrubbing: Bool = false
    var body: some View {
        HStack {
            Spacer()
            ScrubberPreviewImage(imageLoader: preview)
                .frame(width: 150, height: 150 / (16 / 9), alignment: .trailing)
                .border(Color(uiColor: .darkGray))
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .allowsHitTesting(false)
        .opacity(isScrubbing ? 1 : 0)
        .onChange(of: asset) { asset in
            preview.asset = asset as? AVURLAsset
        }
        .onChange(of: player.scrubberSeconds, throttleInterval: 0.2, perform: { seconds in
            guard let seconds else {
                return
            }
            Task {
                await preview.load(at: player.time(forTimeInterval: seconds))
            }
        })
        .task {
            asset = player.asset
        }
        .onReceive(player.isScrubbingPublisher) { newValue in
            guard isScrubbing != newValue
            else { return }
            withAnimation(.spring()) {
                isScrubbing = newValue
            }
        }
    }
}
