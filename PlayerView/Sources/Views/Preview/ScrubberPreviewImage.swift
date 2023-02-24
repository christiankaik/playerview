import SwiftUI

struct ScrubberPreviewImage: View {
    let image: UIImage?

    var body: some View {
        ZStack {
            Color.black

            if let image {
                Image(uiImage: image)
                    .resizable()
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}

struct ScrubberPreviewImage_Previews: PreviewProvider {
    static var previews: some View {
        ScrubberPreviewImage(image: nil)
            .frame(width: 640, height: 640 / (16 / 9))
            .previewLayout(.sizeThatFits)
    }
}
