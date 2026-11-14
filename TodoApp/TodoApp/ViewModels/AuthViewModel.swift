import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var email           = ""
    @Published var password        = ""
    @Published var confirmPassword = ""
    @Published var isLoading       = false
    @Published var errorMessage: String?

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    // MARK: - Validation

    var isLoginFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }

    var isRegisterFormValid: Bool {
        isLoginFormValid &&
        !confirmPassword.isEmpty &&
        password == confirmPassword
    }

    // MARK: - Actions

    func login() async {
        guard isLoginFormValid else {
            errorMessage = "Please enter a valid email and a password of at least 6 characters."
            return
        }
        isLoading    = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await authService.signIn(email: email.trimmingCharacters(in: .whitespaces),
                                         password: password)
        } catch {
            errorMessage = FirebaseErrorHelper.message(from: error)
        }
    }

    func register() async {
        guard isRegisterFormValid else {
            if password != confirmPassword {
                errorMessage = "Passwords do not match."
            } else {
                errorMessage = "Please fill in all fields correctly."
            }
            return
        }
        isLoading    = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await authService.signUp(email: email.trimmingCharacters(in: .whitespaces),
                                         password: password)
        } catch {
            errorMessage = FirebaseErrorHelper.message(from: error)
        }
    }

    func logout() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = FirebaseErrorHelper.message(from: error)
        }
    }

    func clearFields() {
        email           = ""
        password        = ""
        confirmPassword = ""
        errorMessage    = nil
    }
}
