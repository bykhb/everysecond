import Combine
import Foundation
import SwiftUI

class ClockModel: ObservableObject {
    @Published var now: Date = Date()
    private var timer: Timer?

    init() {
        start()
    }

    deinit {
        stop()
    }

    func start() {
        stop()
        // Fire immediately and then every second
        now = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.now = Date()
        }
        // Ensure the timer runs on the common run loop mode so it updates during UI interactions
        RunLoop.current.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // Digital formatting
    func digitalString(includeSeconds: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeStyle = includeSeconds ? .medium : .short
        return formatter.string(from: now)
    }

    // Components for analog clock
    var hourAngle: Angle {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute, .second], from: now)
        let hour = Double(comps.hour ?? 0) .truncatingRemainder(dividingBy: 12)
        let minute = Double(comps.minute ?? 0)
        let second = Double(comps.second ?? 0)
        // 30° per hour + 0.5° per minute + ~0.0083° per second
        return Angle.degrees((hour * 30) + (minute * 0.5) + (second * (0.5/60)))
    }

    var minuteAngle: Angle {
        let cal = Calendar.current
        let comps = cal.dateComponents([.minute, .second], from: now)
        let minute = Double(comps.minute ?? 0)
        let second = Double(comps.second ?? 0)
        // 6° per minute + 0.1° per second
        return Angle.degrees((minute * 6) + (second * 0.1))
    }

    var secondAngle: Angle {
        let cal = Calendar.current
        let comps = cal.dateComponents([.second], from: now)
        let second = Double(comps.second ?? 0)
        // 6° per second
        return Angle.degrees(second * 6)
    }
}

struct ClockView: View {
    @StateObject private var clock = ClockModel()

    var body: some View {
        VStack(spacing: 16) {
            // Analog clock on top
            GeometryReader { geo in
                ZStack {
                    // Face background
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().stroke(Color.secondary.opacity(0.4), lineWidth: 1))

                    // Hour tick marks (12 major)
                    ForEach(0..<12) { i in
                        Rectangle()
                            .fill(Color.primary.opacity(0.8))
                            .frame(width: 2, height: geo.size.width * 0.06)
                            .offset(y: -(geo.size.width / 2) + geo.size.width * 0.06)
                            .rotationEffect(.degrees(Double(i) / 12.0 * 360.0))
                    }

                    // Minute tick marks (lighter)
                    ForEach(0..<60) { i in
                        if i % 5 != 0 { // skip where hour marks are
                            Rectangle()
                                .fill(Color.primary.opacity(0.25))
                                .frame(width: 1, height: geo.size.width * 0.03)
                                .offset(y: -(geo.size.width / 2) + geo.size.width * 0.03)
                                .rotationEffect(.degrees(Double(i) / 60.0 * 360.0))
                        }
                    }

                    // Hour hand
                    Hand(length: 0.35, thickness: 5)
                        .rotationEffect(clock.hourAngle)
                        .animation(.linear(duration: 0.2), value: clock.now)

                    // Minute hand
                    Hand(length: 0.48, thickness: 3)
                        .rotationEffect(clock.minuteAngle)
                        .animation(.linear(duration: 0.2), value: clock.now)

                    // Second hand
                    Hand(length: 0.5, thickness: 1, color: .red)
                        .rotationEffect(clock.secondAngle)
                        .animation(.linear(duration: 0.2), value: clock.now)

                    // Center cap
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 8, height: 8)
                }
                .padding(8)
            }
            .aspectRatio(1, contentMode: .fit)

            // Digital readout below
            Text(clock.digitalString())
                .font(.system(size: 34, weight: .medium, design: .rounded))
                .monospacedDigit()
                .accessibilityLabel("Current time")
        }
        .padding()
    }
}

private struct Hand: View {
    let length: CGFloat
    let thickness: CGFloat
    var color: Color = .primary

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: thickness)
            .frame(maxHeight: .infinity, alignment: .top)
            .overlay(
                Rectangle()
                    .fill(color)
                    .frame(width: thickness, height: 10)
                    .offset(y: -5), alignment: .top
            )
            .mask(
                VStack(spacing: 0) {
                    Rectangle().frame(height: 0) // no tail below center
                    Rectangle().frame(maxHeight: .infinity)
                }
            )
            .padding(.top, 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(color)
                    .frame(width: thickness, height: 2000 * length)
                    .offset(y: -2000 * length / 2)
            }
            .clipped()
    }
}

#Preview("Clock") {
    ClockView()
}
