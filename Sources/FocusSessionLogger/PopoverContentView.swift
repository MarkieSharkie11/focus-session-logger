import SwiftUI

struct PopoverContentView: View {
    @ObservedObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 16) {
            headerView
            Divider()

            switch sessionManager.state {
            case .idle:
                idleView
            case .focusing:
                activeSessionView(label: "Focusing", color: sessionManager.selectedCategory.color)
            case .onBreak:
                activeSessionView(label: "Break", color: .green)
            }

            Divider()
            statsView
        }
        .padding(20)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Image(systemName: "timer")
                .font(.title2)
            Text("Focus Session Logger")
                .font(.headline)
            Spacer()
        }
    }

    // MARK: - Idle View

    private var idleView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Category")
                Spacer()
                Picker("", selection: $sessionManager.selectedCategory) {
                    ForEach(Category.allCases) { category in
                        Label(category.rawValue, systemImage: category.icon)
                            .foregroundStyle(category.color)
                            .tag(category)
                    }
                }
                .pickerStyle(.menu)
                .fixedSize()
            }

            HStack {
                Text("Project")
                Spacer()
                Picker("", selection: $sessionManager.selectedProject) {
                    ForEach(Project.allCases) { project in
                        Label(project.rawValue, systemImage: project.icon)
                            .tag(project)
                    }
                }
                .pickerStyle(.menu)
                .fixedSize()
            }

            Button(action: { sessionManager.startSession() }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Focus Session")
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.2, blue: 0.2),
                                 Color(red: 0.8, green: 0.0, blue: 0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Active Session View

    private func activeSessionView(label: String, color: Color) -> some View {
        VStack(spacing: 16) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1.5)

            Text(sessionManager.formattedTimeRemaining)
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundStyle(color)

            if sessionManager.state == .focusing {
                VStack(spacing: 6) {
                    Label(sessionManager.selectedCategory.rawValue,
                          systemImage: sessionManager.selectedCategory.icon)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(sessionManager.selectedCategory.color)
                    Label(sessionManager.selectedProject.rawValue,
                          systemImage: sessionManager.selectedProject.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: progress)
                .tint(color)

            if sessionManager.state == .focusing {
                Button(role: .destructive) {
                    sessionManager.cancelSession()
                } label: {
                    Text("Cancel Session")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
            }
        }
    }

    // MARK: - Stats View

    private var statsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Text("\(sessionManager.sessionsCompletedToday) sessions")
                    .font(.subheadline)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Focus Time")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Text(formattedTotalTime)
                    .font(.subheadline)
            }
        }
    }

    // MARK: - Helpers

    private var progress: Double {
        let total: TimeInterval
        switch sessionManager.state {
        case .idle:
            return 0
        case .focusing:
            total = SessionManager.focusDuration
        case .onBreak:
            total = SessionManager.breakDuration
        }
        let elapsed = total - TimeInterval(sessionManager.secondsRemaining)
        return elapsed / total
    }

    private var formattedTotalTime: String {
        let minutes = sessionManager.totalFocusMinutesToday
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}
