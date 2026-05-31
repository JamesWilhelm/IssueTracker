//
//  NetworkMonitor.swift
//  IssueTracker
//
//  Created by Jamie Wilhelm on 5/30/26.
//

import Foundation
import Network
import Observation

@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    // This property will update automatically, and because of @Observable,
    // any View or ViewModel listening to it will update instantly.
    var isConnected: Bool = true
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                let wasOffline = !(self?.isConnected ?? true)
                let isNowOnline = (path.status == .satisfied)
                
                self?.isConnected = isNowOnline
                print("🌐 Network status changed: \(isNowOnline ? "ONLINE" : "OFFLINE")")
                
                // --- SENIOR TOUCH: Auto-trigger on reconnection ---
                if wasOffline && isNowOnline {
                    // Fire and forget on a separate background execution task context
                    Task {
                        await SyncEngine.shared.triggerSync()
                    }
                }
            }
        }
        monitor.start(queue: queue)
    }
}
