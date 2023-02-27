import AVFoundation
import SwiftUI

struct CPlayerView: View {
    private let scrubber: Scrubber
    private let player: Player

    @StateObject private var viewModel: CPlayerViewModel
    @State private var showControls: Bool = true

    init(player: AVPlayer) {
        let playerObject = Player(player: player)

        self.player = playerObject
        self.scrubber = Scrubber(player: self.player)
        _viewModel = StateObject(wrappedValue: .init(player: playerObject))
    }

    var body: some View {
        ZStack {
            VideoContentView(scrubber.player)
                .onTapGesture {
                    withAnimation(.spring()) {
                        showControls.toggle()
                    }
                }

            PlayerOverlayView(scrubber: scrubber, showControls: $showControls)
                .padding()
        }
        .persistentSystemOverlays(.hidden)
        .background(.black)
        .alert(isPresented: $viewModel.isError, error: viewModel.error) { error in
            // Lets ignore this for now
        } message: { error in
            if let failureReason = error.failureReason {
                Text(failureReason)
            } else {
                Text("Something went wrong")
            }
        }

    }
}

struct CPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        CPlayerView(player: AVPlayer(url: streamUrl))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
