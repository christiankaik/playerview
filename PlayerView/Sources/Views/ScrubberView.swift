import SwiftUI

extension ScrubberView {
    private static let normalHeight: CGFloat = 4
    private static let normalHeightCornerRadius: CGFloat = 2

    private static let maxHeight: CGFloat = 16
    private static let maxHeightCornerRadius: CGFloat = 8

    enum ScrubbingState: Equatable {
        case inactive
        case pressing
        case scrubbing(translation: CGSize)

        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .scrubbing:
                return true
            }
        }

        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .scrubbing(let translation):
                return translation
            }
        }
    }
}

struct ScrubberView: View {
    @Binding var value: Double

    let minTrackColor: Color
    let maxTrackColor: Color
    let onScrubbing: ((Bool, Double?) -> Void)

    @GestureState private var gestureState: ScrubbingState = .inactive

    private var translation: CGSize { gestureState.translation }
    private var offsetY: CGFloat { (Self.maxHeight - height) / 2 }

    private var height: CGFloat {
        gestureState.isDragging ?
        Self.maxHeight :
        Self.normalHeight
    }

    private var cornerRadius: CGFloat {
        gestureState.isDragging ?
        Self.maxHeightCornerRadius :
        Self.normalHeightCornerRadius
    }

    private var scaleEffect: CGSize {
        return CGSize(
            width: (gestureState == .pressing) ? 0.99 : 1,
            height: (gestureState == .pressing) ? 1.2 : 1
        )
    }

    init(value: Binding <Double>,
         minTrackColor: Color = .accentColor,
         maxTrackColor: Color = .gray,
         coordinateSpace: PlayerCoordinateSpace = .playerControls,
         onScrubbing: @escaping ((Bool, Double?) -> Void)
    ) {
        _value = value
        self.minTrackColor = minTrackColor
        self.maxTrackColor = maxTrackColor
        self.onScrubbing = onScrubbing
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(maxTrackColor)
                Rectangle()
                    .fill(minTrackColor)
                    .frame(width: makeValueWidth(for: proxy))
            }.cornerRadius(cornerRadius)
            .gesture(makeGesture(with: proxy))
            .frame(height: height)
            .scaleEffect(scaleEffect)
            .offset(y: offsetY)
            .animation(.interactiveSpring(), value: height)
            .animation(.interactiveSpring(), value: scaleEffect)
            .preference(key: ScrubberFrameKey.self, value: proxy.frame(in: .playerControls))
        }
        .frame(height: Self.maxHeight)
        .onChange(of: gestureState) { state in
            guard state == .inactive else {
                return
            }
            onScrubbing(false, nil)
        }
    }

    private func makeGesture(with proxy: GeometryProxy) -> some Gesture {
        LongPressGesture(minimumDuration: 0.2)
            .onEnded { ended in
                guard ended else {
                    onScrubbing(false, nil)
                    return
                }
                onScrubbing(true, value)
            }
            .sequenced(before: DragGesture())
            .updating($gestureState) { gestureSequence, state, _ in
                switch gestureSequence {
                case .first(true):
                    state = .pressing
                case .second(true, let drag):
                    let translation = drag?.translation ?? .zero
                    state = .scrubbing(translation: translation)
                    onScrubbing(true, makeValue(translation: translation, for: proxy))
                default:
                    return
                }
            }
            .onEnded { gesture in
                guard case .second(_, let drag?) = gesture else {
                    onScrubbing(false, nil)
                    return
                }
                value = makeValue(translation: drag.translation, for: proxy)
                onScrubbing(false, value)
            }
    }

    private func makeValue(translation: CGSize, for proxy: GeometryProxy) -> CGFloat {
        let translation = translation.width / proxy.size.width
        return (value + translation).clamped(minimum: 0, maximum: 1)
    }

    private func makeValueWidth(for proxy: GeometryProxy) -> CGFloat {
        proxy.size.width * makeValue(translation: gestureState.translation, for: proxy)
    }
}

struct ScrubberView_Previews: PreviewProvider {
    @State static var test: Double = 0.5

    static var previews: some View {
        ScrubberView(value: $test, onScrubbing: { _, _  in })
            .padding()
    }
}
