import SwiftUI

import AVFoundation

struct ScrubberPreviewImage: View {
    @ObservedObject var imageLoader: AssetImageLoader
    var body: some View {
        ZStack {
            Color.black

            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
            } else if imageLoader.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}

struct ScrubberPreviewImage_Previews: PreviewProvider {
    static var previews: some View {
        ScrubberPreviewImage(imageLoader: .init(asset: nil, maximumWidth: 150))
            .frame(width: 640, height: 640 / (16 / 9))
            .previewLayout(.sizeThatFits)
    }
}
