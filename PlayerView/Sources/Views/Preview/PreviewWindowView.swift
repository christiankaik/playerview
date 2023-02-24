import SwiftUI

struct PreviewWindowView: View {
    @StateObject private var viewModel: PreviewWindowViewModel

    init(scrubber: Scrubber) {
        _viewModel = StateObject(wrappedValue: PreviewWindowViewModel(scrubber: scrubber, maximumWidth: 150))
    }

    var body: some View {
        ScrubberPreviewImage(image: viewModel.image)
            .frame(width: 150, height: 150 / (16 / 9))
            .allowsHitTesting(false)
            .border(Color(uiColor: .darkGray))
        //.opacity(viewModel.isScrubbing ? 1 : 0)
    }
}
