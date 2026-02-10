import Foundation

struct TodayStats {
    let count: Int
    let totalMinutes: Int
}

final class SessionLogger {
    private let fileManager = FileManager.default

    private var logDirectory: URL {
        fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Documents/FocusLogs")
    }

    private var todayFilename: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date()) + ".md"
    }

    private var todayFileURL: URL {
        logDirectory.appendingPathComponent(todayFilename)
    }

    func log(session: CompletedSession) {
        ensureDirectoryExists()

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: session.startTime)

        let row = "| \(timeString) | \(session.durationMinutes) min | \(session.category.rawValue) | \(session.project.rawValue) |"

        if fileManager.fileExists(atPath: todayFileURL.path) {
            appendRow(row)
        } else {
            createNewLog(firstRow: row)
        }

        updateSummary()
    }

    func todayStats() -> TodayStats {
        guard fileManager.fileExists(atPath: todayFileURL.path),
              let content = try? String(contentsOf: todayFileURL, encoding: .utf8) else {
            return TodayStats(count: 0, totalMinutes: 0)
        }

        let lines = content.components(separatedBy: "\n")
        var count = 0
        var totalMinutes = 0

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("|"), !trimmed.hasPrefix("| Time"),
                  !trimmed.hasPrefix("|---"), !trimmed.hasPrefix("| **Total") else {
                continue
            }
            let columns = trimmed.components(separatedBy: "|")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            guard columns.count == 4 else { continue }
            let durationStr = columns[1].replacingOccurrences(of: " min", with: "")
            if let minutes = Int(durationStr) {
                count += 1
                totalMinutes += minutes
            }
        }

        return TodayStats(count: count, totalMinutes: totalMinutes)
    }

    private func ensureDirectoryExists() {
        try? fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true)
    }

    private func createNewLog(firstRow: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let dateHeader = dateFormatter.string(from: Date())

        let content = """
        # Focus Log — \(dateHeader)

        | Time | Duration | Category | Project |
        |------|----------|----------|---------|
        \(firstRow)

        ---

        | **Total Focus Time** | **25 min** | | |
        """

        try? content.write(to: todayFileURL, atomically: true, encoding: .utf8)
    }

    private func appendRow(_ row: String) {
        guard var content = try? String(contentsOf: todayFileURL, encoding: .utf8) else { return }

        // Insert the new row before the "---" separator
        if let separatorRange = content.range(of: "\n---\n") {
            content.insert(contentsOf: "\n\(row)", at: separatorRange.lowerBound)
        } else {
            // Fallback: just append
            content += "\n\(row)"
        }

        try? content.write(to: todayFileURL, atomically: true, encoding: .utf8)
    }

    private func updateSummary() {
        guard var content = try? String(contentsOf: todayFileURL, encoding: .utf8) else { return }
        let stats = todayStats()

        let hours = stats.totalMinutes / 60
        let mins = stats.totalMinutes % 60
        let formatted: String
        if hours > 0 {
            formatted = "\(hours) hr \(mins) min"
        } else {
            formatted = "\(mins) min"
        }

        let summaryLine = "| **Total Focus Time** | **\(formatted)** | | |"

        // Replace existing summary line
        let lines = content.components(separatedBy: "\n")
        var newLines: [String] = []
        for line in lines {
            if line.contains("**Total Focus Time**") {
                newLines.append(summaryLine)
            } else {
                newLines.append(line)
            }
        }

        content = newLines.joined(separator: "\n")
        try? content.write(to: todayFileURL, atomically: true, encoding: .utf8)
    }
}
