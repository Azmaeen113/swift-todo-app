# TodoApp — SwiftUI + Firebase

A beginner-friendly iOS Todo List app built with **SwiftUI** and **Firebase** (Authentication + Cloud Firestore) for a Mobile Computing Lab assignment.

---

## Features

| Area | What's included |
|---|---|
| **Auth** | Email/password registration, login, logout, input validation, friendly error messages |
| **Tasks** | Add, edit, delete (with confirmation), toggle completion |
| **Firestore** | Real-time updates, per-user data isolation |
| **UI** | Clean SwiftUI, loading indicators, empty state, swipe-to-delete/edit, FAB |

---

## Project Structure

```
TodoApp/
├── TodoApp/
│   ├── TodoAppApp.swift          # App entry point, FirebaseApp.configure()
│   ├── ContentView.swift         # Auth-state router (Login ↔ Home)
│   ├── Models/
│   │   └── TodoItem.swift        # Codable Firestore model
│   ├── Services/
│   │   ├── AuthService.swift     # Firebase Auth wrapper (ObservableObject)
│   │   └── TodoService.swift     # Firestore CRUD + real-time listener
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift   # Login / Register business logic
│   │   └── TodoViewModel.swift   # Task list business logic
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── LoginView.swift
│   │   │   ├── RegisterView.swift
│   │   │   └── AuthTextField.swift
│   │   └── Todo/
│   │       ├── HomeView.swift    # Task list + FAB
│   │       ├── TodoRowView.swift # Single task row with swipe actions
│   │       └── TodoFormView.swift# Add / Edit sheet
│   └── Utilities/
│       └── FirebaseErrorHelper.swift
├── Package.swift                 # Firebase via Swift Package Manager
└── firestore.rules               # Firestore security rules
```

---

## Prerequisites

- **macOS** with Xcode 15 or later
- An **Apple Developer** account (free tier is fine for the simulator)
- A **Firebase** project (free Spark plan works)

---

## Firebase Setup

### Step 1 — Create a Firebase project

1. Go to <https://console.firebase.google.com/> and click **Add project**.
2. Give it a name (e.g. `TodoApp`) and follow the wizard.

### Step 2 — Enable Authentication

1. In your project, navigate to **Build → Authentication → Get started**.
2. Under the **Sign-in method** tab, enable **Email/Password**.

### Step 3 — Create a Firestore database

1. Navigate to **Build → Firestore Database → Create database**.
2. Choose **Start in production mode** (you'll deploy proper security rules shortly).
3. Pick a region close to you and confirm.

### Step 4 — Register your iOS app

1. In the Firebase Console home, click the **iOS+** icon.
2. Enter your **Bundle ID** — it must exactly match what's in Xcode (e.g. `com.yourname.TodoApp`).
3. Download **`GoogleService-Info.plist`**.
4. **Do NOT commit this file to Git.** It is already listed in `.gitignore`.

### Step 5 — Add `GoogleService-Info.plist` to Xcode

1. Open `TodoApp.xcodeproj` (or `.xcworkspace`) in Xcode.
2. Drag `GoogleService-Info.plist` into the **TodoApp** target group in the Project Navigator.
3. Make sure **"Copy items if needed"** is checked and the file is added to the **TodoApp** target.

### Step 6 — Deploy Firestore security rules

Option A — Firebase CLI (recommended):

```bash
# Install the Firebase CLI if you haven't already
npm install -g firebase-tools

# Log in
firebase login

# In the project root (where firestore.rules lives)
firebase init firestore   # select your project, accept defaults
firebase deploy --only firestore:rules
```

Option B — Firebase Console:

1. Open **Firestore Database → Rules**.
2. Copy the contents of `firestore.rules` and paste them in.
3. Click **Publish**.

---

## Xcode Setup

### Step 1 — Open the project

```bash
open TodoApp/TodoApp.xcodeproj
```

### Step 2 — Add Firebase via Swift Package Manager

> If the dependencies aren't resolved automatically, follow these steps:

1. In Xcode: **File → Add Package Dependencies…**
2. Enter the URL: `https://github.com/firebase/firebase-ios-sdk`
3. Choose **Up to Next Major Version** starting at `11.0.0`.
4. Select the following products and add them to the **TodoApp** target:
   - `FirebaseAuth`
   - `FirebaseFirestore`

### Step 3 — Set the Bundle ID

1. Click the **TodoApp** project in the navigator.
2. Under **Targets → TodoApp → Signing & Capabilities**, set **Bundle Identifier** to match the one you registered in Firebase (e.g. `com.yourname.TodoApp`).

### Step 4 — Build and run

Select a simulator (iPhone 15, iOS 17+) and press **⌘R**.

---

## Running the App — Quick Test Flow

1. **Register** — tap "Sign Up", enter an email and password (≥ 6 chars), confirm and submit.
2. **Login** — you'll be redirected to the Home screen automatically after registration.
3. **Add a task** — tap the blue **+** button, fill in a title (description is optional), tap "Add Task".
4. **Complete a task** — tap the circle on the left of any task.
5. **Edit a task** — swipe left on a task and tap the blue **Edit** button.
6. **Delete a task** — swipe left and tap **Delete**, then confirm in the dialog.
7. **Logout** — tap the logout icon (↩) in the top-right corner.

---

## Firestore Data Model

Collection: `todos`

| Field | Type | Description |
|---|---|---|
| `title` | `String` | Task title (required, max 200 chars) |
| `description` | `String` | Task description (optional, max 1 000 chars) |
| `isCompleted` | `Boolean` | Completion state |
| `uid` | `String` | Firebase Auth UID of the owner |
| `createdAt` | `Timestamp` | Creation timestamp |

---

## Security Rules Summary

- A user can only **read, create, update, and delete** documents where the `uid` field matches their own Firebase Auth UID.
- `create` validates that `title` is non-empty (≤ 200 chars) and `description` ≤ 1 000 chars.
- `update` prevents changing the `uid` or `createdAt` fields.
- Everything else is **denied by default**.

---

## Git Setup

```bash
cd f:/E/Downloads/todoapp-swift
git init
git add .
git commit -m "Initial commit — SwiftUI + Firebase TodoApp"

# Push to GitHub
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

> ⚠️ **Never push `GoogleService-Info.plist`.** It is excluded in `.gitignore`, but always double-check with `git status` before pushing.

---

## Common Issues

| Symptom | Fix |
|---|---|
| *"No such module 'Firebase'"* | Make sure SPM dependencies are resolved: **File → Packages → Resolve Package Versions** |
| App crashes on launch | Ensure `GoogleService-Info.plist` is added to the target (not just the filesystem) |
| *"Missing or insufficient permissions"* | Deploy or update `firestore.rules`; check that the `uid` field is being saved correctly |
| Simulator has no network | Reset the simulator: **Device → Erase All Content and Settings** |
| Auth error 17010 (too many attempts) | Wait a few minutes; Firebase rate-limits repeated failed logins |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9+ |
| UI | SwiftUI (iOS 16+) |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Dependency manager | Swift Package Manager |
| Firebase SDK | firebase-ios-sdk 11.x |

---

## License

This project is for educational purposes (Mobile Computing Lab assignment).
