import SwiftUI

struct RegisterView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AuthViewModel
    @EnvironmentObject private var authService: AuthService

    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // MARK: Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue)
                        Text("Create Account")
                            .font(.largeTitle.bold())
                        Text("Join TodoApp to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 32)

                    // MARK: Fields
                    VStack(spacing: 14) {
                        AuthTextField(title: "Email",
                                      icon: "envelope",
                                      text: $viewModel.email,
                                      keyboardType: .emailAddress)

                        AuthTextField(title: "Password (min. 6 characters)",
                                      icon: "lock",
                                      text: $viewModel.password,
                                      isSecure: true)

                        AuthTextField(title: "Confirm Password",
                                      icon: "lock.shield",
                                      text: $viewModel.confirmPassword,
                                      isSecure: true)
                    }
                    .padding(.horizontal)

                    // MARK: Error
                    if let error = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }

                    // MARK: Register button
                    Button {
                        Task {
                            await viewModel.register()
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.isRegisterFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(!viewModel.isRegisterFormValid || viewModel.isLoading)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
