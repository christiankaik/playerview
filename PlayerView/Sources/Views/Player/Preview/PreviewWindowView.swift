import SwiftUI

struct PreviewWindowView: View {
    @StateObject private var viewModel: PreviewWindowViewModel

    @State private var image: UIImage?

    private let width: CGFloat

    private var height: CGFloat {
        width / (16 / 9)
    }

    init(scrubber: Scrubber, width: CGFloat) {
        _viewModel = StateObject(wrappedValue: PreviewWindowViewModel(scrubber: scrubber, maximumWidth: width))
        self.width = width
    }

    var body: some View {
        ScrubberPreviewImage(image: image)
            .onReceive(viewModel.$image.throttle(for: 0.5, scheduler: RunLoop.main, latest: true)) { image in
                self.image = image
            }
            .frame(width: width, height: height)
            .allowsHitTesting(false)
            .border(Color(uiColor: .darkGray))
            .opacity(viewModel.show ? 1 : 0)
            .animation(.spring(), value: viewModel.isScrubbing)
    }
}
