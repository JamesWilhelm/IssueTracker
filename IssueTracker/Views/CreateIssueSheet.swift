//
//  CreateIssueSheet.swift
//  IssueTracker
//
//  Created by Jamie Wilhelm on 5/31/26.
//

import SwiftUI

struct CreateIssueSheet: View {
    @Bindable var viewModel: IssueListVM
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $viewModel.newIssueTitle)
                TextField("Description (Optional)", text: $viewModel.newIssueDescription, axis: .vertical)
                    .lineLimit(3...5)
            }
            .navigationTitle("New Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { viewModel.isShowingCreateSheet = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task { await viewModel.createIssue() }
                    }
                    .disabled(viewModel.newIssueTitle.isEmpty)
                }
            }
        }
    }
}
