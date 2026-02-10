import Foundation
import SwiftUI

enum Category: String, CaseIterable, Identifiable {
    case deepWork = "Deep Work"
    case designReview = "Design Review"
    case meetings = "Meetings"
    case planning = "Planning"
    case learning = "Learning"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .deepWork: return .indigo
        case .designReview: return .orange
        case .meetings: return .teal
        case .planning: return .purple
        case .learning: return .green
        }
    }

    var icon: String {
        switch self {
        case .deepWork: return "brain.head.profile"
        case .designReview: return "eye"
        case .meetings: return "person.3.fill"
        case .planning: return "map"
        case .learning: return "book.fill"
        }
    }
}

enum Project: String, CaseIterable, Identifiable {
    case snowflake = "Snowflake"
    case portfolio = "Portfolio"
    case personal = "Personal"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .snowflake: return "snowflake"
        case .portfolio: return "briefcase.fill"
        case .personal: return "person.fill"
        }
    }
}

enum SessionState: Equatable {
    case idle
    case focusing
    case onBreak
}

struct CompletedSession {
    let startTime: Date
    let endTime: Date
    let category: Category
    let project: Project
    let durationMinutes: Int
}
