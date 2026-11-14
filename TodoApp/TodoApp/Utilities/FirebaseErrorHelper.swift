import Foundation

/// Maps common Firebase / Auth error codes to user-friendly messages.
struct FirebaseErrorHelper {

    static func message(from error: Error) -> String {
        let nsError = error as NSError
        // Firebase Auth errors carry an `AuthErrorCode` inside their domain
        if nsError.domain == "FIRAuthErrorDomain" {
            switch nsError.code {
            case 17007: return "An account with this email already exists."
            case 17008: return "The email address is badly formatted."
            case 17009: return "Incorrect password. Please try again."
            case 17011: return "No account found with this email."
            case 17026: return "Password must be at least 6 characters."
            case 17020: return "No internet connection. Please check your network."
            case 17010: return "Too many failed attempts. Try again later."
            default:    return nsError.localizedDescription
            }
        }
        // Firestore errors
        if nsError.domain == "FIRFirestoreErrorDomain" {
            switch nsError.code {
            case 7:  return "You don't have permission to perform this action."
            case 14: return "Could not connect to the server. Check your network."
            default: return nsError.localizedDescription
            }
        }
        return error.localizedDescription
    }
}
