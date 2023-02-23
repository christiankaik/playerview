import SwiftUI

struct PlayPauseView: View {
    let isPlaying: Bool
    let isSeeking: Bool

    var body: some View {
        Group {
            if isSeeking {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 26))
            }
        }
        .frame(width: 32, height: 32)
    }
}

struct PlayPauseView_Previews: PreviewProvider {
    static var previews: some View {
        PlayPauseView(isPlaying: true, isSeeking: false)
    }
}
