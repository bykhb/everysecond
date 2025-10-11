import SwiftUI

struct LEDClockView: View {
    var date: Date
    var timeFormat: String = "HH:mm" // or "HH:mm:ss"
    var foreground: Color = Color(red: 0.60, green: 0.85, blue: 1.0) // light blue
    var glow: Color = Color(red: 0.25, green: 0.55, blue: 1.0)       // deeper blue
    var panelColor: Color = .black
    var fontSize: CGFloat = 120

    private var timeString: String {
        let f = DateFormatter()
        f.dateFormat = timeFormat
        return f.string(from: date)
    }

    var body: some View {
        Text(timeString)
            .font(.system(size: fontSize, weight: .semibold, design: .rounded))
            .kerning(6)
            .foregroundStyle(foreground)
            .shadow(color: glow.opacity(0.8), radius: 18, x: 0, y: 0)
            .shadow(color: glow.opacity(0.5), radius: 36, x: 0, y: 0)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(panelColor.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 14, x: 0, y: 8)
            )
            .accessibilityLabel("Digital clock")
    }
}

#Preview {
    VStack(spacing: 24) {
        LEDClockView(date: Date())
        LEDClockView(date: Date(), timeFormat: "HH:mm:ss")
    }
    .padding()
}
