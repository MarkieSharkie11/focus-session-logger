import Foundation
import Combine
import SwiftUI

final class SessionManager: ObservableObject {
    static let focusDuration: TimeInterval = 25 * 60
    static let breakDuration: TimeInterval = 5 * 60

    @Published var state: SessionState = .idle
    @Published var secondsRemaining: Int = Int(focusDuration)
    @Published var selectedCategory: Category = .deepWork
    @Published var selectedProject: Project = .snowflake
    @Published var sessionsCompletedToday: Int = 0
    @Published var totalFocusMinutesToday: Int = 0

    private var timer: Timer?
    private var sessionStartTime: Date?
    private let logger = SessionLogger()

    var formattedTimeRemaining: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    init() {
        loadTodayStats()
    }

    func startSession() {
        withAnimation(.easeInOut(duration: 0.3)) { state = .focusing }
        secondsRemaining = Int(Self.focusDuration)
        sessionStartTime = Date()
        startTimer()
    }

    func cancelSession() {
        stopTimer()
        withAnimation(.easeInOut(duration: 0.3)) { state = .idle }
        secondsRemaining = Int(Self.focusDuration)
        sessionStartTime = nil
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard secondsRemaining > 0 else { return }
        secondsRemaining -= 1

        if secondsRemaining <= 0 {
            handleTimerComplete()
        }
    }

    private func handleTimerComplete() {
        stopTimer()

        switch state {
        case .focusing:
            completeFocusSession()
        case .onBreak:
            completeBreak()
        case .idle:
            break
        }
    }

    private func completeFocusSession() {
        let endTime = Date()

        if let startTime = sessionStartTime {
            let session = CompletedSession(
                startTime: startTime,
                endTime: endTime,
                category: selectedCategory,
                project: selectedProject,
                durationMinutes: 25
            )
            logger.log(session: session)
            sessionsCompletedToday += 1
            totalFocusMinutesToday += 25
        }

        NotificationManager.shared.sendNotification(
            title: "Focus Session Complete",
            body: "Great work! Take a 5-minute break."
        )

        withAnimation(.easeInOut(duration: 0.3)) { state = .onBreak }
        secondsRemaining = Int(Self.breakDuration)
        startTimer()
    }

    private func completeBreak() {
        NotificationManager.shared.sendNotification(
            title: "Break Over",
            body: "Ready for another focus session?"
        )
        withAnimation(.easeInOut(duration: 0.3)) { state = .idle }
        secondsRemaining = Int(Self.focusDuration)
        sessionStartTime = nil
    }

    private func loadTodayStats() {
        let stats = logger.todayStats()
        sessionsCompletedToday = stats.count
        totalFocusMinutesToday = stats.totalMinutes
    }
}
