//
//  Issue.swift
//  IssueTracker
//
//  Created by Jamie Wilhelm on 5/29/26.
//

import Foundation
import SwiftData

enum IssueStatus: String, Codable, CaseIterable {
    case backlog = "Backlog"
    case todo = "Todo"
    case inProgress = "In Progress"
    case done = "Done"
}

@Model
final class Issue {
    @Attribute(.unique) var id: UUID
    var title: String
    var issueDescription: String
    var status: IssueStatus
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        issueDescription: String = "",
        status: IssueStatus = .todo,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.issueDescription = issueDescription
        self.status = status
        self.updatedAt = updatedAt
    }
}
