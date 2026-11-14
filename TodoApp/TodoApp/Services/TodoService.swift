import Foundation
import FirebaseFirestore

/// Handles all Firestore CRUD operations for TodoItem.
final class TodoService {

    private let db = Firestore.firestore()
    private let collectionName = "todos"

    // MARK: - Real-time listener

    /// Attaches a snapshot listener that calls `onChange` whenever the user's tasks change.
    /// Returns the listener handle so the caller can detach it.
    func listenToTodos(uid: String, onChange: @escaping ([TodoItem], Error?) -> Void) -> ListenerRegistration {
        db.collection(collectionName)
            .whereField("uid", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error {
                    onChange([], error)
                    return
                }
                let items = (snapshot?.documents ?? []).compactMap { doc -> TodoItem? in
                    try? doc.data(as: TodoItem.self)
                }
                onChange(items, nil)
            }
    }

    // MARK: - Create
    func addTodo(_ item: TodoItem) async throws {
        try db.collection(collectionName).addDocument(from: item)
    }

    // MARK: - Update
    func updateTodo(_ item: TodoItem) async throws {
        guard let id = item.id else { throw TodoServiceError.missingID }
        try db.collection(collectionName).document(id).setData(from: item)
    }

    // MARK: - Delete
    func deleteTodo(id: String) async throws {
        try await db.collection(collectionName).document(id).delete()
    }

    // MARK: - Toggle completion
    func toggleCompletion(_ item: TodoItem) async throws {
        guard let id = item.id else { throw TodoServiceError.missingID }
        try await db.collection(collectionName).document(id).updateData([
            "isCompleted": !item.isCompleted
        ])
    }
}

enum TodoServiceError: LocalizedError {
    case missingID

    var errorDescription: String? {
        switch self {
        case .missingID: return "Task ID is missing. Please try again."
        }
    }
}
