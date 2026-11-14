import Foundation
import FirebaseAuth

/// Wraps Firebase Authentication so ViewModels stay thin.
final class AuthService: ObservableObject {

    @Published var currentUser: User? = Auth.auth().currentUser

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
