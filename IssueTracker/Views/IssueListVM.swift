//
//  IssueListVM.swift
//  IssueTracker
//
//  Created by Jamie Wilhelm on 5/29/26.
//

import Foundation
import Observation

@Observable
@MainActor  // Ensures all UI state updates happen safely on the Main Thread
final class IssueListVM {
    // Dependencies
    private let repository: IssueRepositoryProtocol

    // UI State
    var issues: [Issue] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    // --- TESTING CONTROLS ---
    // Toggle this to true to seed 100 tickets automatically
    var useMockData: Bool = false

    // Form State for creating a new issue
    var newIssueTitle: String = ""
    var newIssueDescription: String = ""
    var isShowingCreateSheet: Bool = false

    // Fix: Remove the default "= IssueRepository()" parameter assignment
    init(repository: IssueRepositoryProtocol) {
        self.repository = repository
    }

    func loadIssues() async {
        isLoading = true
        errorMessage = nil
        do {
            issues = try await repository.fetchIssues()
            
            #if DEBUG
            if useMockData && issues.isEmpty {
                try await injectMockData()
            }
            #endif
            
            // --- Wake up the sync engine to clear the queue if online ---
            Task {
                await SyncEngine.shared.triggerSync()
            }
            
        } catch {
            errorMessage = "Failed to load issues: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func injectMockData() async throws { 
        for mockIssue in Issue.mockList {
            let _ = try await repository.createIssue(
                title: mockIssue.title,
                description: mockIssue.issueDescription
            )
        }
        issues = try await repository.fetchIssues()
    }

    // Helper to clear the database when turning mock mode off
    func clearAllData() async {
        isLoading = true
        do {
            for issue in issues {
                try await repository.deleteIssue(id: issue.id)
            }
            issues = []
        } catch {
            errorMessage = "Failed to clear data: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func createIssue() async {
        guard !newIssueTitle.isEmpty else { return }

        do {
            // 1. Save to local storage (creates local issue + drops item in outbox queue)
            let _ = try await repository.createIssue(
                title: newIssueTitle,
                description: newIssueDescription
            )

            // 2. Refresh the UI list
            await loadIssues()

            // 3. Reset form state
            newIssueTitle = ""
            newIssueDescription = ""
            isShowingCreateSheet = false
        } catch {
            errorMessage = "Failed to save issue: \(error.localizedDescription)"
        }
    }

    func updateStatus(for issue: Issue, to newStatus: IssueStatus) async {
        do {
            // Now you can pass it straight through without a messy rawValue fallback!
            try await repository.updateIssueStatus(id: issue.id, newStatus: newStatus)
            await loadIssues()
        } catch {
            errorMessage = "Failed to update status: \(error.localizedDescription)"
        }
    }

    func deleteIssue(_ issue: Issue) async {
        do {
            try await repository.deleteIssue(id: issue.id)
            // Refresh the list to reflect the deletion
            await loadIssues()
        } catch {
            errorMessage =
                "Failed to delete issue: \(error.localizedDescription)"
        }
    }
}
