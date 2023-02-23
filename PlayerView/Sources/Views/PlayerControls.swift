import SwiftUI
import AVFoundation

struct PlayerControls: View {
    @ObservedObject var player: PlayerController
    @State private var progress: Double = 0
    @State private var durationMode: DurationDisplayMode = .endDateTime
    @State private var isScrubbing: Bool = false
    let onInteract: (InteractionType) -> Void

    private enum DurationDisplayMode: CaseIterable {
        case differenceToCurrentTime
        case duration
        case endDateTime
    }

    enum InteractionType {
        case playPause
        case skip
        case scrub
        case switchTimeDisplay
    }

    var time: String {
        if let seconds = player.scrubberSeconds, isScrubbing {
            return seconds.durationFormatted
        } else {
            return player.currentTimeSeconds.durationFormatted
        }
    }

    var duration: String {
        switch durationMode {
        case .differenceToCurrentTime:
            return "-\((player.duration - player.currentTimeSeconds).durationFormatted)"
        case .duration:
            return player.duration.durationFormatted
        case .endDateTime:
            let toEndTimeInterval = player.duration - player.currentTimeSeconds
            return Date()
                .addingTimeInterval(toEndTimeInterval)
                .durationFormatted
        }
    }

    var body: some View {
        HStack {
            Button {
                player.seekBackward(by: 10)
                onInteract(.skip)
            } label: {
                Image(systemName: "gobackward.10")
            }.disabled(player.isSeeking)
            Button {
                player.playPause()
                onInteract(.skip)
            } label: {
                PlayPauseView(
                    isPlaying: player.isPlaying,
                    isSeeking: player.isSeeking
                )
            }
            Button {
                player.seekForward(by: 10)
                onInteract(.skip)
            } label: {
                Image(systemName: "goforward.10")
            }.disabled(player.isSeeking)
            Text(time)
                .font(.caption)
                .frame(width: 44, alignment: .leading)
                .fixedSize(horizontal: true, vertical: true)
            Scrubber(
                value: $progress,
                minTrackColor: .white,
                maxTrackColor: Color(uiColor: .lightGray)
            ) { scrubbing, progress in
                player.scrub(scrubbing, to: progress)
                onInteract(.scrub)
            }
            .opacity(0.7)
            .onChange(of: player.progress) { value in
                progress = value
            }
            Text(duration)
                .font(.caption)
                .frame(width: 44, alignment: .trailing)
                .fixedSize(horizontal: true, vertical: true)
                .onTapGesture {
                    durationMode = durationMode.next()
                    onInteract(.switchTimeDisplay)
                }
        }
        .preferredColorScheme(.dark)
        .tint(.white.opacity(0.7))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(idealHeight: 100)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .onReceive(player.isScrubbingPublisher) { newValue in
            guard isScrubbing != newValue
            else { return }
            isScrubbing = newValue
        }
        .task {
            player.isScrubbingSubject.value = false
        }
    }
}

 struct PlayerControls_Previews: PreviewProvider {
    static var previews: some View {
        PlayerControls(player: PlayerController(url: streamUrl), onInteract: { _ in })
            .previewLayout(.sizeThatFits)
    }
 }
