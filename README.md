```markdown
# Offline-First Issue Tracker

A production-ready, highly optimized iOS application built with **SwiftUI** and **SwiftData** demonstrating advanced offline-first architecture. This project showcases thread-safe data synchronization, background actor isolation, unidirectional data flow, and compile-time type safety designed to meet senior-level engineering standards.

---

## 🛠 Architectural Design & Core Concepts

This application is engineered around an **Offline-First / Local-First** mental model. The local database is always treated as the single source of truth for the user interface, while remote synchronization happens implicitly, asynchronously, and entirely off the main thread.

### 1. Isolated Sync Engine (Swift Actor)
To guarantee that database serialization and network dispatching never block the UI thread or cause frame drops (hitching), the synchronization orchestration runs completely isolated inside a background Swift `actor`. The `SyncEngine` handles cross-context management by instantiating private background `ModelContext` instances, ensuring zero contention with the main-actor bound UI.

### 2. Transactional Write-Ahead Outbox (The Outbox Pattern)
Instead of relying on ephemeral state tracking or immediate network responses, mutations performed while offline are recorded atomically as a discrete `SyncAction` transaction. 
* When a write operation occurs (e.g., creating an issue, updating a status), the change is committed to the local database alongside a corresponding outbox record in a single atomic transaction.
* This guarantees data resiliency; if the app crashes, kills its background execution, or loses power, the exact intended user mutation is safe on disk.
* Upon network restoration via `NWPathMonitor`, the `SyncEngine` wakes up, fetches the pending log chronologically, replays the payloads sequentially against a mock REST backend, and clears the outbox log on verified success.

### 3. Compile-Time Type Safety
To avoid systemic issues common with loosely-typed string payloads (e.g., misinterpreting status states), the core lifecycle state is driven by a native `IssueStatus` enum conforming to `Codable` and `CaseIterable`. This forces the compiler to validate status transitions from the View layer, through the Repository, down into the SQL schema serialization layer.

---

## 📂 Codebase Directory Layout

The codebase enforces strict **Separation of Concerns** by grouping functional layers into clean, domain-specific modules, optimizing scannability and structural maintainability:

```text
📦 IssueTracker
 ┣ 📂 App
 ┃ ┣ 📜 IssueTrackerApp.swift      # Application lifecycle and persistence entry point
 ┃ ┗ 🏞️ Assets.xcassets            # Media assets & asset catalog design tokens
 ┣ 📂 Core
 ┃ ┣ 📂 Storage
 ┃ ┃ ┗ 📜 StorageProvider.swift    # Central container configuration for SwiftData schemas
 ┃ ┗ 📂 Networking
 ┃   ┣ 📜 NetworkMonitor.swift     # NWPathMonitor network capability state broadcaster
 ┃   ┗ 📜 SyncEngine.swift         # Background pipeline synchronization actor
 ┣ 📂 Models
 ┃ ┣ 📜 Issue.swift                # Persistent Data Model and status enum definitions
 ┃ ┗ 📜 SyncAction.swift           # Transactional write-ahead outbox log entity
 ┣ 📂 Repositories
 ┃ ┗ 📜 IssueRepository.swift      # Protocol-oriented data abstraction execution layer
 ┣ 📂 Features
 ┃ ┗ 📂 IssueList
 ┃   ┣ 📜 IssueListView.swift      # Declarative reactive user interface layout views
 ┃   ┗ 📜 IssueListVM.swift        # MainActor-isolated reactive presentation View Model
 ┗ 📂 Mocks / Debug
   ┗ 📜 Issue+Mock.swift           # Deterministic structural mock data generation logic
