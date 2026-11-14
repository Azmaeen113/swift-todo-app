import Foundation
import FirebaseFirestore

/// Represents a single Todo task stored in Firestore.
struct TodoItem: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var isCompleted: Bool
    var uid: String          // Owner's Firebase UID
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case isCompleted
        case uid
        case createdAt
    }

    init(id: String? = nil,
         title: String,
         description: String,
         isCompleted: Bool = false,
         uid: String,
         createdAt: Date = Date()) {
        self.id          = id
        self.title       = title
        self.description = description
        self.isCompleted = isCompleted
        self.uid         = uid
        self.createdAt   = createdAt
    }
}
