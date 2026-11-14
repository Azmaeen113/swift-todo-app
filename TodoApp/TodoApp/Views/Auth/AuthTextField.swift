import SwiftUI

/// Reusable styled text field used across Auth screens.
struct AuthTextField: View {
    let title: String
    let icon:  String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)

            if isSecure {
                SecureField(title, text: $text)
                    .textContentType(title.lowercased().contains("confirm") ? .newPassword : .password)
                    .autocapitalization(.none)
            } else {
                TextField(title, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
