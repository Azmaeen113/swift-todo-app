import SwiftUI

/// Sheet used for both adding and editing a task.
struct TodoFormView: View {

    @Environment(\.dismiss) private var dismiss

    /// Pass a non-nil item to edit it; nil means "add new".
    let existingItem: TodoItem?
    let onSave: (String, String) async -> Void

    @State private var title       = ""
    @State private var description = ""
    @State private var isSaving    = false

    private var isEditing: Bool { existingItem != nil }

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty || isSaving
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title *", text: $title)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Button {
                        Task {
                            isSaving = true
                            await onSave(title, description)
                            isSaving = false
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Text(isEditing ? "Save Changes" : "Add Task")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isSaveDisabled)
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                // Pre-fill fields when editing
                if let item = existingItem {
                    title       = item.title
                    description = item.description
                }
            }
        }
    }
}
