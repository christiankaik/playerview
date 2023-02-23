import AVFoundation
import Foundation
import UIKit

class AVPlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    // swiftlint:disable force_cast
    // This is a standard practice and is generally safe
    // as long as the corresponding class var is updated along with this force cast
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
}
