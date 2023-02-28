import AVFoundation
import SwiftUI

struct CPlayerView: View {
    private let scrubber: Scrubber
    private let player: Player

    @StateObject private var viewModel: CPlayerViewModel
    @State private var showControls = true
    @State private var videoGravityResizeAspect = true

    @Binding var isPresented: Bool

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onEnded { scale in
                videoGravityResizeAspect = scale < 1
            }
    }

    init(player: AVPlayer, isPresented: Binding<Bool>) {
        let playerObject = Player(player: player)

        self.player = playerObject
        self.scrubber = Scrubber(player: self.player)
        _viewModel = StateObject(wrappedValue: .init(player: playerObject))
        _isPresented = isPresented
    }

    var body: some View {
        ZStack {
            VideoContentView(scrubber.player, videoGravityResizeAspect: $videoGravityResizeAspect)
                .onTapGesture {
                    withAnimation(.spring()) {
                        showControls.toggle()
                    }
                }
                .gesture(zoomGesture)

            PlayerOverlayView(
                scrubber: scrubber,
                showControls: $showControls,
                videoGravityResizeAspect: $videoGravityResizeAspect,
                isPresented: _isPresented
            )
            .padding()
        }
        .persistentSystemOverlays(.hidden)
        .background(.black)
        .preferredColorScheme(.dark)
        .tint(.white.opacity(0.7))
        .alert(isPresented: $viewModel.isError, error: viewModel.error) { error in
            Button("Too Bad 😕") {
                isPresented = false
            }
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
        CPlayerView(player: AVPlayer(url: streamUrl), isPresented: .constant(true))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
