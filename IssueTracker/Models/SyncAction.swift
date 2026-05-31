//
//  SyncAction.swift
//  IssueTracker
//
//  Created by Jamie Wilhelm on 5/29/26.
//

import Foundation
import SwiftData

@Model
final class SyncAction {
    @Attribute(.unique) var id: UUID
    var issueId: UUID
    var actionType: String // "create", "update", "delete"
    var payload: Data?     // Encoded JSON of the changes to send to the server
    var createdAt: Date
    
    init(id: UUID = UUID(), issueId: UUID, actionType: String, payload: Data? = nil, createdAt: Date = Date()) {
        self.id = id
        self.issueId = issueId
        self.actionType = actionType
        self.payload = payload
        self.createdAt = createdAt
    }
}
