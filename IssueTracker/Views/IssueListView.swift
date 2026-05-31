//
//  IssueListView.swift
//  IssueTracker
//
//  Created by Jamie Wilhelm on 5/29/26.
//

import SwiftUI

struct IssueListView: View {
    // Senior note: Use @State for @Observable view models instantiated by the view
    @State private var viewModel = IssueListVM(repository: IssueRepository())
    @State private var networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        NavigationStack {
            if !networkMonitor.isConnected {
                HStack {
                    Image(systemName: "wifi.slash")
                    Text("Working Offline — Changes will sync later")
                        .font(.caption)
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(.orange.opacity(0.8))
                .foregroundStyle(.white)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            Group {
                if viewModel.isLoading && viewModel.issues.isEmpty {
                    ProgressView("Loading your dashboard...")
                } else if viewModel.issues.isEmpty {
                    ContentUnavailableView(
                        "No Issues Found",
                        systemImage: "checklist",
                        description: Text("Tap the '+' button to log an issue offline.")
                    )
                } else {
                    List {
                        ForEach(viewModel.issues) { issue in
                            IssueRowView(issue: issue, onStatusChange: { nextStatus in
                                Task { await viewModel.updateStatus(for: issue, to: nextStatus) }
                            })
                            // --- SENIOR TOUCH: Swipe Actions Engine ---
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task { await viewModel.deleteIssue(issue) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.loadIssues()
                    }
                }
            }
            .navigationTitle("Issue Tracker")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.isShowingCreateSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingCreateSheet) {
                CreateIssueSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.loadIssues()
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}


