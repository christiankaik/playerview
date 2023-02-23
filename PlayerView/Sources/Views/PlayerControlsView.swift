import SwiftUI

struct PlayerControlsView: View {
    @ObservedObject var player: PlayerController
    @Binding var showControls: Bool
    @State private var idleTimer: Timer?

    var body: some View {
        VStack {
            Spacer()
            PlayerControls(player: player) { interaction in
                guard interaction == .switchTimeDisplay
                else { return }
                refreshIdleTimer()
            }
            .padding()
        }
        .opacity(showControls ? 1 : 0)
        .onReceive(player.$isPlaying, perform: { isPlaying in
            if isPlaying {
                refreshIdleTimer()
            } else {
                cancelIdleTimer()
            }
        })
        .onChange(of: showControls) {
            cancelIdleTimer()
            if $0 && player.isPlaying {
                setupIdleTimer()
            }
        }
    }

    private func refreshIdleTimer() {
        cancelIdleTimer()
        setupIdleTimer()
    }

    private func cancelIdleTimer() {
        idleTimer?.invalidate()
    }

    private func setupIdleTimer() {
        idleTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: timerFired(_:))
    }

    private func timerFired(_: Timer) {
        withAnimation {
            showControls = false
        }
    }
}
