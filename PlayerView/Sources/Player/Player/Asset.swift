import Foundation
import AVFoundation

final class Asset {
    let asset: AVAsset

    init?(_ asset: AVAsset?) {
        if let asset {
            self.asset = asset
        } else {
            return nil
        }
    }
}
