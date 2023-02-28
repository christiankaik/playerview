import Foundation
import SwiftUI

struct PlayerOverlayView: View {
    @StateObject private var viewModel: PlayerOverlayViewModel

    private let scrubber: Scrubber

    @Binding var showControls: Bool
    @Binding var videoGravityResizeAspect: Bool
    @Binding var isPresented: Bool

    init(scrubber: Scrubber, showControls: Binding<Bool>, videoGravityResizeAspect: Binding<Bool>, isPresented: Binding<Bool>) {
        self.scrubber = scrubber
        _showControls = showControls
        _videoGravityResizeAspect = videoGravityResizeAspect
        _viewModel = StateObject(wrappedValue: .init(scrubber: scrubber))
        _isPresented = isPresented
    }

    var body: some View {
        VStack(alignment: .leading) {
            PlayerTopControlsView(
                videoGravityResizeAspect: _videoGravityResizeAspect,
                isPresented: _isPresented,
                onInteract: refreshIdleTimer
            )

            Spacer()

            PlayerBottomControlsView(scrubber: scrubber, onInteract: refreshIdleTimer)
        }
        .opacity(showControls ? 1 : 0)
        .onReceive(viewModel.$showControls) { showControls in
            withAnimation {
                self.showControls = showControls
            }
        }
        .onChange(of: showControls) { showControls in
            guard showControls else {
                return
            }

            refreshIdleTimer()
        }
    }

    private func refreshIdleTimer() {
        viewModel.refreshIdleTimerIfPlaying()
    }
}
