import Foundation

struct PlaylistItem: Identifiable, Codable {
    let id: UUID
    let title: String?
    let url: URL

    init(title: String?, url: String) {
        self.id = UUID()
        self.title = title
        self.url = URL(string: url)!
    }
}
