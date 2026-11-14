import SwiftUI

/// Root view: switches between Login and Home depending on auth state.
struct ContentView: View {

    @EnvironmentObject private var authService: AuthService

    var body: some View {
        Group {
            if let user = authService.currentUser {
                HomeView(uid: user.uid)
            } else {
                LoginView(authService: authService)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.currentUser?.uid)
    }
}
