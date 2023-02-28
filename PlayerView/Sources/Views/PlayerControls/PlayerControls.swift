import SwiftUI
import Combine

struct PlayerControls: View {
    typealias OnInteract = () -> Void

    @StateObject private var viewModel: PlayerControlsModel
    @State private var progress: Double = 0

    let onInteract: OnInteract?

    init(scrubber: Scrubber, onInteract: OnInteract?) {
        _viewModel = StateObject(wrappedValue: PlayerControlsModel(scrubber: scrubber))
        self.onInteract = onInteract
    }

    var body: some View {
        HStack {
            Button {
                viewModel.player.seekOffset(by: -10)
                onInteract?()
            } label: {
                Image(systemName: "gobackward.10")
            }.disabled(viewModel.isSeeking)

            Button {
                viewModel.player.playPause()
                onInteract?()
            } label: {
                PlayPauseView(
                    isPlaying: viewModel.isPlaying,
                    isSeeking: viewModel.isSeeking
                )
            }
            
            Button {
                viewModel.player.seekOffset(by: 10)
                onInteract?()
            } label: {
                Image(systemName: "goforward.10")
            }.disabled(viewModel.isSeeking)

            Text(viewModel.time)
                .font(.caption)
                .frame(width: 44, alignment: .leading)
                .fixedSize(horizontal: true, vertical: true)

            ScrubberView(
                value: $progress,
                minTrackColor: .white,
                maxTrackColor: Color(uiColor: .lightGray),
                coordinateSpace: .playerControls
            ) { scrubbing, progress in
                viewModel.scrubber.scrub(scrubbing, to: progress)
                onInteract?()
            }
            .opacity(0.7)
            .onReceive(viewModel.$progress) { value in
                progress = value
            }

            Text(viewModel.endTime)
                .font(.caption)
                .frame(width: 44, alignment: .trailing)
                .fixedSize(horizontal: true, vertical: true)
                .onTapGesture {
                    viewModel.cycleDurationMode()
                    onInteract?()
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(idealHeight: 100)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .task {
            viewModel.scrubber.scrub(false, to: nil)
        }
    }
}
