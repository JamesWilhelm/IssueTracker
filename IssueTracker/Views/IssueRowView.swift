//
//  IssureRowView.swift
//  IssueTracker
//
//  Created by Jamie Wilhelm on 5/31/26.
//
import SwiftUI

struct IssueRowView: View {
    let issue: Issue
    var onStatusChange: (IssueStatus) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(issue.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if !issue.issueDescription.isEmpty {
                    Text(issue.issueDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer()
            
            Menu {
                ForEach(IssueStatus.allCases, id: \.self) { status in
                    Button(status.rawValue) {
                        onStatusChange(status)
                    }
                }
            } label: {
                Text(issue.status.rawValue)
                    .font(.caption)
                    .bold()
                    .frame(width: 85, height: 24)
                    .background(statusColor(issue.status).opacity(0.15))
                    .foregroundStyle(statusColor(issue.status))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(statusColor(issue.status), lineWidth: 1.5)
        )
        .animation(.snappy, value: issue.status)
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    private func statusColor(_ status: IssueStatus) -> Color {
        switch status {
        case .inProgress: return .blue
        case .done: return .green
        default: return .secondary
        }
    }
}
