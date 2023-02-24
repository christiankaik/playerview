import Foundation
import SwiftUI

enum PlayerCoordinateSpace: String {
    case playerControls
}

extension View {
    func coordinateSpace(_ coordinateSpace: PlayerCoordinateSpace) -> some View {
        self.coordinateSpace(name: coordinateSpace.rawValue)
    }
}

extension GeometryProxy {
    func frame(in coordinateSpace: PlayerCoordinateSpace) -> CGRect {
        self.frame(in: .named(coordinateSpace.rawValue))
    }
}
