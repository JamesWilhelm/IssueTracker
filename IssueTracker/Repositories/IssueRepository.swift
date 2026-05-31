//
//  IssueRepository.swift
//  IssueTracker
//
//  Created by Jamie Wilhelm on 5/29/26.
//

import Foundation
import SwiftData

protocol IssueRepositoryProtocol {
    func fetchIssues() async throws -> [Issue]
    func createIssue(title: String, description: String) async throws -> Issue
    func updateIssueStatus(id: UUID, newStatus: IssueStatus) async throws
    func deleteIssue(id: UUID) async throws
}

@MainActor
final class IssueRepository: IssueRepositoryProtocol {
    private let context: ModelContext
    
    // Fix: Make the parameter optional in the signature
        init(context: ModelContext? = nil) {
            if let context = context {
                self.context = context
            } else {
                // Safe: Inside the init body, the compiler respects the @MainActor isolation
                self.context = StorageProvider.shared.mainContext
            }
        }
    
    func fetchIssues() async throws -> [Issue] {
        let descriptor = FetchDescriptor<Issue>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        return try context.fetch(descriptor)
    }
    
    func createIssue(title: String, description: String) async throws -> Issue {
        let newIssue = Issue(title: title, issueDescription: description)
        context.insert(newIssue)
        
        //Encode the payload for the server
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let uploadData = [
            "id": newIssue.id.uuidString,
            "title": newIssue.title,
            "description": newIssue.issueDescription,
            "status": newIssue.status.rawValue
        ]
        
        let payloadData = try? encoder.encode(uploadData)
        
        let syncAction = SyncAction(issueId: newIssue.id, actionType: "create", payload: payloadData)
        context.insert(syncAction)
        
        try context.save()
        return newIssue
    }
    
    func deleteIssue(id: UUID) async throws {
        let predicate = #Predicate<Issue> { $0.id == id }
        var descriptor = FetchDescriptor<Issue>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        if let issue = try context.fetch(descriptor).first {
            // 1. Delete the item from the local context
            context.delete(issue)
            
            // 2. Drop a "delete" action payload into the sync outbox queue
            let syncAction = SyncAction(issueId: id, actionType: "delete")
            context.insert(syncAction)
            
            // 3. Atomically commit changes
            try context.save()
        }
    }
    
    func updateIssueStatus(id: UUID, newStatus: IssueStatus) async throws {
        let predicate = #Predicate<Issue> { $0.id == id }
        var descriptor = FetchDescriptor<Issue>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        if let issue = try context.fetch(descriptor).first {
            issue.status = newStatus
            issue.updatedAt = Date()
            
            // When logging to the outbox, we can pass the raw string value to the payload
            let uploadData = ["status": newStatus.rawValue]
            let payloadData = try? JSONEncoder().encode(uploadData)
            
            let syncAction = SyncAction(issueId: id, actionType: "update", payload: payloadData)
            context.insert(syncAction)
            
            try context.save()
        }
    }
}
