import Foundation
import Combine

enum TimeDisplayMode: String, CaseIterable, Identifiable {
    case stopwatch
    case clock
    var id: String { rawValue }
}

final class TimeTracker: ObservableObject {
    @Published var displayMode: TimeDisplayMode = .stopwatch

    private lazy var clockFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        return df
    }()

    // Published properties observed by SwiftUI
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var isRunning: Bool = false

    @Published private(set) var currentClockString: String = ""

    var displayString: String {
        switch displayMode {
        case .stopwatch:
            return formattedTime(elapsedTime)
        case .clock:
            return currentClockString
        }
    }

    private var timer: Timer?
    private var startDate: Date?

    init() {
        currentClockString = clockFormatter.string(from: Date())
    }

    // Starts the timer if not already running
    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        startDate = Date() - elapsedTime
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    // Starts clock updates (independent of stopwatch)
    func startClockUpdates() {
        // Reuse timer if not running; create a 1s tick for clock
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.tick()
            }
            RunLoop.main.add(timer!, forMode: .common)
        }
        // Immediately update once
        tick()
    }

    func stopClockUpdatesIfNeeded() {
        // Only stop timer if not running stopwatch
        if !isRunning {
            timer?.invalidate()
            timer = nil
        }
    }

    // Stops the timer if running
    func stopTimer() {
        guard isRunning else { return }
        isRunning = false
        timer?.invalidate()
        timer = nil
        if displayMode == .clock {
            startClockUpdates()
        }
        // Preserve elapsedTime; keep startDate for potential resume logic
    }

    // Resets the timer to zero and stops it
    func resetTimer() {
        stopTimer()
        elapsedTime = 0
        startDate = nil
        if displayMode == .clock {
            currentClockString = clockFormatter.string(from: Date())
        }
    }

    // Formats a TimeInterval as HH:MM:SS.t (tenths)
    func formattedTime(_ interval: TimeInterval) -> String {
        let totalTenths = Int((interval * 10).rounded(.down))
        let hours = totalTenths / 36000
        let minutes = (totalTenths % 36000) / 600
        let seconds = (totalTenths % 600) / 10
        let tenths = totalTenths % 10
        if hours > 0 {
            return String(format: "%02d:%02d:%02d.%d", hours, minutes, seconds, tenths)
        } else {
            return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
        }
    }

    // Updates elapsed time or clock string depending on mode and state
    private func tick() {
        if isRunning, let startDate = startDate {
            elapsedTime = Date().timeIntervalSince(startDate)
        }
        if displayMode == .clock {
            currentClockString = clockFormatter.string(from: Date())
        }
    }

    func setDisplayMode(_ mode: TimeDisplayMode) {
        displayMode = mode
        switch mode {
        case .stopwatch:
            // If we were only showing clock, stop timer; if stopwatch running, startTimer will recreate its timer
            stopClockUpdatesIfNeeded()
        case .clock:
            // Ensure stopwatch is stopped and start clock ticking
            if isRunning {
                stopTimer()
            }
            startClockUpdates()
        }
    }
}
