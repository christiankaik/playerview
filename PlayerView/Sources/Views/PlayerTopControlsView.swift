import SwiftUI

private extension View {
    func topControlsButtonStyle() -> some View {
        self.padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

struct PlayerTopControlsView: View {
    @Binding var videoGravityResizeAspect: Bool
    @Binding var isPresented: Bool

    let onInteract: () -> Void

    var zoomSymbolName: String {
        videoGravityResizeAspect ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left"
    }

    var body: some View {
        HStack {
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
            }
            .topControlsButtonStyle()

            Spacer()

            Button {
                videoGravityResizeAspect.toggle()
                onInteract()
            } label: {
                Image(systemName: zoomSymbolName)
            }
            .topControlsButtonStyle()
        }
    }
}
