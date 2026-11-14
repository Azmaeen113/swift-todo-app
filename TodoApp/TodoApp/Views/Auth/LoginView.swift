import SwiftUI

struct LoginView: View {

    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel: AuthViewModel

    @State private var showRegister = false

    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // MARK: Header
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(.blue)
                        Text("TodoApp")
                            .font(.largeTitle.bold())
                        Text("Sign in to manage your tasks")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 48)

                    // MARK: Fields
                    VStack(spacing: 14) {
                        AuthTextField(title: "Email",
                                      icon: "envelope",
                                      text: $viewModel.email,
                                      keyboardType: .emailAddress)

                        AuthTextField(title: "Password",
                                      icon: "lock",
                                      text: $viewModel.password,
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

                    // MARK: Login button
                    Button {
                        Task { await viewModel.login() }
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.isLoginFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(!viewModel.isLoginFormValid || viewModel.isLoading)
                    .padding(.horizontal)

                    // MARK: Register link
                    Button {
                        viewModel.clearFields()
                        showRegister = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundColor(.secondary)
                            Text("Sign Up")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        .font(.subheadline)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showRegister) {
                RegisterView(authService: authService)
            }
        }
    }
}
