import SwiftUI

struct PreviewWindowView: View {
    @StateObject private var viewModel: PreviewWindowViewModel

    init(scrubber: Scrubber) {
        _viewModel = StateObject(wrappedValue: PreviewWindowViewModel(scrubber: scrubber, maximumWidth: 150))
    }

    var body: some View {
        HStack {
            Spacer()
            ScrubberPreviewImage(image: viewModel.image)
                .frame(width: 150, height: 150 / (16 / 9), alignment: .trailing)
                .border(Color(uiColor: .darkGray))
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .allowsHitTesting(false)
        .opacity(viewModel.isScrubbing ? 1 : 0)
    }
}
