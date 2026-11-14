import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel: TodoViewModel

    @State private var showAddForm    = false
    @State private var itemToEdit:  TodoItem?
    @State private var showSignOutAlert = false

    init(uid: String) {
        _viewModel = StateObject(wrappedValue: TodoViewModel(uid: uid))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {

                // MARK: - Content
                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading tasks…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.todos.isEmpty {
                        emptyState
                    } else {
                        taskList
                    }
                }

                // MARK: - FAB
                Button {
                    showAddForm = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSignOutAlert = true
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.todos.isEmpty {
                        Text("\(viewModel.todos.count) task\(viewModel.todos.count == 1 ? "" : "s")")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            // Add sheet
            .sheet(isPresented: $showAddForm) {
                TodoFormView(existingItem: nil) { title, description in
                    await viewModel.addTodo(title: title, description: description)
                }
            }
            // Edit sheet
            .sheet(item: $itemToEdit) { item in
                TodoFormView(existingItem: item) { title, description in
                    await viewModel.updateTodo(item, title: title, description: description)
                }
            }
            // Error alert
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.clearError() } }
            )) {
                Button("OK", role: .cancel) { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            // Sign-out alert
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    // AuthViewModel handles errors but we can call service directly
                    try? authService.signOut()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }

    // MARK: - Empty state
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray.fill")
                .font(.system(size: 64))
                .foregroundStyle(.quaternary)
            Text("No Tasks Yet")
                .font(.title2.bold())
                .foregroundColor(.secondary)
            Text("Tap the + button to add your first task.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Task list
    private var taskList: some View {
        List {
            ForEach(viewModel.todos) { item in
                TodoRowView(
                    item: item,
                    onToggle: { Task { await viewModel.toggleCompletion(item) } },
                    onEdit:   { itemToEdit = item },
                    onDelete: { Task { await viewModel.deleteTodo(item) } }
                )
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: viewModel.todos.map(\.id))
    }
}
