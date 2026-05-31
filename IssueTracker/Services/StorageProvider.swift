//
//  StorageProvider.swift
//  IssueTracker
//
//  Created by Jamie Wilhelm on 5/29/26.
//

import Foundation
import SwiftData

@MainActor
final class StorageProvider {
    // The single container managing the database schema
    static let shared = StorageProvider()
    
    let container: ModelContainer
    let mainContext: ModelContext
    
    private init() {
        do {
            // Define the schema with our two models
            let schema = Schema([Issue.self, SyncAction.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            self.container = try ModelContainer(for: schema, configurations: [configuration])
            self.mainContext = container.mainContext
            
            // Ensures changes on background contexts automatically merge into the UI context
            self.mainContext.autosaveEnabled = true
        } catch {
            fatalError("Failed to initialize SwiftData Container: \(error.localizedDescription)")
        }
    }
    
    // Call this whenever the Sync Engine needs to do background work
    func createBackgroundContext() -> ModelContext {
        let context = ModelContext(container)
        // Background contexts should not process undo stacks to save memory
        context.undoManager = nil
        return context
    }
}
