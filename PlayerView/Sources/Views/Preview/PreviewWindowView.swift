import SwiftUI

struct PreviewWindowView: View {
    @StateObject private var viewModel: PreviewWindowViewModel

    private let width: CGFloat

    private var height: CGFloat {
        width / (16 / 9)
    }

    init(scrubber: Scrubber, width: CGFloat) {
        _viewModel = StateObject(wrappedValue: PreviewWindowViewModel(scrubber: scrubber, maximumWidth: width))
        self.width = width
    }

    var body: some View {
        ScrubberPreviewImage(image: viewModel.image)
            .frame(width: width, height: height)
            .allowsHitTesting(false)
            .border(Color(uiColor: .darkGray))
            .opacity(viewModel.isScrubbing ? 1 : 0)
            .animation(.spring(), value: viewModel.isScrubbing)
    }
}
