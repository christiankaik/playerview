import SwiftUI

struct PlayerTopControlsView: View {
    @Binding var videoGravityResizeAspect: Bool

    let onInteract: () -> Void

    var zoomSymbolName: String {
        videoGravityResizeAspect ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left"
    }

    var body: some View {
        HStack {
            Spacer()

            Button {
                videoGravityResizeAspect.toggle()
                onInteract()
            } label: {
                Image(systemName: zoomSymbolName)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }
}
