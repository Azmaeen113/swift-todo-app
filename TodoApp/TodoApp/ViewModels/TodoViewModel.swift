import Foundation
import FirebaseFirestore

@MainActor
final class TodoViewModel: ObservableObject {

    @Published var todos:        [TodoItem] = []
    @Published var isLoading:    Bool       = false
    @Published var errorMessage: String?

    private let todoService = TodoService()
    private var listener:   ListenerRegistration?
    private let uid:        String

    init(uid: String) {
        self.uid = uid
        startListening()
    }

    deinit {
        listener?.remove()
    }

    // MARK: - Real-time listener

    private func startListening() {
        isLoading = true
        listener  = todoService.listenToTodos(uid: uid) { [weak self] items, error in
            guard let self else { return }
            self.isLoading = false
            if let error {
                self.errorMessage = FirebaseErrorHelper.message(from: error)
            } else {
                self.todos = items
            }
        }
    }

    // MARK: - Add

    func addTodo(title: String, description: String) async {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Task title cannot be empty."
            return
        }
        let newItem = TodoItem(title: trimmedTitle,
                               description: description.trimmingCharacters(in: .whitespaces),
                               uid: uid)
        do {
            try await todoService.addTodo(newItem)
        } catch {
            errorMessage = FirebaseErrorHelper.message(from: error)
        }
    }

    // MARK: - Update

    func updateTodo(_ item: TodoItem, title: String, description: String) async {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Task title cannot be empty."
            return
        }
        var updated         = item
        updated.title       = trimmedTitle
        updated.description = description.trimmingCharacters(in: .whitespaces)
        do {
            try await todoService.updateTodo(updated)
        } catch {
            errorMessage = FirebaseErrorHelper.message(from: error)
        }
    }

    // MARK: - Delete

    func deleteTodo(_ item: TodoItem) async {
        guard let id = item.id else { return }
        do {
            try await todoService.deleteTodo(id: id)
        } catch {
            errorMessage = FirebaseErrorHelper.message(from: error)
        }
    }

    // MARK: - Toggle

    func toggleCompletion(_ item: TodoItem) async {
        do {
            try await todoService.toggleCompletion(item)
        } catch {
            errorMessage = FirebaseErrorHelper.message(from: error)
        }
    }

    func clearError() { errorMessage = nil }
}
