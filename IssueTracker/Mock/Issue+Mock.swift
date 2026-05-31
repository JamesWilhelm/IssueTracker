//
//  Issue+Mock.swift.swift
//  IssueTracker
//
//  Created by Jamie Wilhelm on 5/30/26.
//

import Foundation

extension Issue {
    static var mockList: [Issue] {
        let sampleDescriptions = [
            "The login button becomes completely unresponsive if the user switches from Wi-Fi to Cellular data while typing their password. Needs immediate attention.",
            "Short text description.",
            "When pulling down to refresh on the dashboard view, the progress indicator doesn't dismiss itself after the data fetch completes. It stays stuck spinning indefinitely until the app is backgrounded and resumed.",
            "Typo on the onboarding screen setup wizard step 3. The word 'Environment' is spelled incorrectly as 'Enviroment'. Low priority but quick fix.",
            "An absolute wall of text to thoroughly stress test our new layout constraints. This description should stretch across multiple lines, pushing the boundaries of our custom card overlay border to ensure that our capsules, spacing, and inner paddings don't break or overlap into neighboring list rows under heavy layout pressure.",
            "" // Empty description test case
        ]
        
        let statuses: [IssueStatus] = [.todo, .inProgress, .done, .backlog]
        
        // Generate 100 uniquely randomized mock issues
        return (1...100).map { index in
            Issue(
                title: "🔴 Bug ticket #\(index): \(index % 2 == 0 ? "Critical Database Desync" : "UI Layout Glitch")",
                issueDescription: sampleDescriptions.randomElement() ?? "",
                status: statuses.randomElement() ?? .todo, // 👈 Updated fallback
                updatedAt: Date().addingTimeInterval(TimeInterval(-index * 3600))
            )
        }
    }
}
