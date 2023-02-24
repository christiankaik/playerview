import SwiftUI

struct PlayerControlsView: View {
    @StateObject private var viewModel: PlayerControlsViewModel
    @Binding var showControls: Bool

    init(scrubber: Scrubber, showControls: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: PlayerControlsViewModel(scrubber: scrubber))
        _showControls = showControls
    }

    var body: some View {
        PlayerControls(scrubber: viewModel.scrubber) {
            viewModel.refreshIdleTimerIfPlaying()
        }
        .opacity(showControls ? 1 : 0)
        .onReceive(viewModel.$showControls) { showControls in
            withAnimation {
                self.showControls = showControls
            }
        }
    }
}
