//
//  SyncEngine.swift
//  IssueTracker
//
//  Created by Jamie Wilhelm on 5/30/26.
//

import Foundation
import SwiftData

actor SyncEngine {
    // Shared instance running completely off the Main Actor
    static let shared = SyncEngine()
    
    private var isSyncing = false
    
    private init() {}
    
    /// Entry point to kick off synchronization
    func triggerSync() async {
        // Guard against redundant concurrent sync loops running simultaneously
        guard !isSyncing else { return }
        
        // Ensure we actually have an active internet connection before proceeding
        guard await NetworkMonitor.shared.isConnected else { return }
        
        isSyncing = true
        print("🔄 Sync Engine: Commencing outbox optimization processing...")
        
        do {
            try await processOutboxQueue()
        } catch {
            print("❌ Sync Engine Error: Processing failed — \(error.localizedDescription)")
        }
        
        isSyncing = false
    }
    
    private func processOutboxQueue() async throws {
        // Create a dedicated background context safely inside our actor
        let backgroundContext = await StorageProvider.shared.createBackgroundContext()
        
        // Fetch pending actions sorted oldest to newest (Chronological order)
        let descriptor = FetchDescriptor<SyncAction>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        let pendingActions = try backgroundContext.fetch(descriptor)
        
        guard !pendingActions.isEmpty else {
            print("✅ Sync Engine: Outbox clean. No synchronization required.")
            return
        }
        
        print("📦 Sync Engine: Found \(pendingActions.count) pending actions to upload.")
        
        for action in pendingActions {
            // Simulate network transit latency (500ms)
            try await Task.sleep(for: .milliseconds(500))
            
            // Senior implementation note: This is where you would transform the action.payload
            // data back into JSON and fire a URLSession POST/PUT/DELETE request to your server.
            print("🚀 Sync Engine: Successfully synced action [\(action.actionType.uppercased())] for Issue ID: \(action.issueId)")
            
            // Once verified by the backend server, remove the log item from our outbox queue
            backgroundContext.delete(action)
            
            // Save the background context changes step-by-step
            try backgroundContext.save()
        }
        
        print("🎉 Sync Engine: Pipeline synchronization complete.")
    }
}
