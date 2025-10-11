import SwiftUI

struct AnalogClockView: View {
    var date: Date
    var faceColor: Color = .secondary.opacity(0.15)
    var tickColor: Color = .secondary
    var hourHandColor: Color = .primary
    var minuteHandColor: Color = .primary
    var secondHandColor: Color = .red
    var showNumbers: Bool = true

    private var calendar: Calendar { Calendar.current }

    private var components: DateComponents {
        calendar.dateComponents([.hour, .minute, .second], from: date)
    }

    private var hourAngle: Angle {
        let h = Double(components.hour ?? 0).truncatingRemainder(dividingBy: 12)
        let m = Double(components.minute ?? 0)
        let s = Double(components.second ?? 0)
        return Angle.degrees((h / 12.0) * 360.0 + (m / 60.0) * 30.0 + (s / 3600.0) * 30.0)
    }

    private var minuteAngle: Angle {
        let m = Double(components.minute ?? 0)
        let s = Double(components.second ?? 0)
        return Angle.degrees((m / 60.0) * 360.0 + (s / 60.0) * 6.0)
    }

    private var secondAngle: Angle {
        let s = Double(components.second ?? 0)
        return Angle.degrees((s / 60.0) * 360.0)
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2

            ZStack {
                // Face
                Circle()
                    .fill(faceColor)
                Circle()
                    .stroke(tickColor.opacity(0.5), lineWidth: 2)

                // Hour ticks
                ForEach(0..<12) { i in
                    TickMark(length: size * 0.08, width: 3)
                        .fill(tickColor)
                        .offset(y: -radius + size * 0.06)
                        .rotationEffect(.degrees(Double(i) / 12.0 * 360.0))
                }

                // Minute ticks
                ForEach(0..<60) { i in
                    if i % 5 != 0 {
                        TickMark(length: size * 0.04, width: 1)
                            .fill(tickColor.opacity(0.7))
                            .offset(y: -radius + size * 0.06)
                            .rotationEffect(.degrees(Double(i) / 60.0 * 360.0))
                    }
                }

                // Numbers
                if showNumbers {
                    ForEach(1..<13) { i in
                        Text("\(i)")
                            .font(.system(size: size * 0.08, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .position(numberPosition(for: i, in: size))
                    }
                }

                // Hands
                Hand(length: radius * 0.5, width: 6)
                    .fill(hourHandColor)
                    .rotationEffect(hourAngle)
                Hand(length: radius * 0.7, width: 4)
                    .fill(minuteHandColor)
                    .rotationEffect(minuteAngle)
                Hand(length: radius * 0.85, width: 2)
                    .fill(secondHandColor)
                    .rotationEffect(secondAngle)

                // Center cap
                Circle()
                    .fill(.primary)
                    .frame(width: 8, height: 8)
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel("Analog clock")
    }

    private func numberPosition(for number: Int, in size: CGFloat) -> CGPoint {
        let angle = Double(number) / 12.0 * 2 * Double.pi - Double.pi / 2
        let radius = size * 0.75 / 2
        let x = size / 2 + CGFloat(cos(angle)) * radius
        let y = size / 2 + CGFloat(sin(angle)) * radius
        return CGPoint(x: x, y: y)
    }
}

private struct TickMark: Shape {
    var length: CGFloat
    var width: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let x = rect.midX
        let yStart = rect.midY
        p.addRoundedRect(in: CGRect(x: x - width/2, y: yStart - length, width: width, height: length), cornerSize: CGSize(width: width/2, height: width/2))
        return p
    }
}

private struct Hand: Shape {
    var length: CGFloat
    var width: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        p.addRoundedRect(in: CGRect(x: center.x - width/2, y: center.y - length, width: width, height: length), cornerSize: CGSize(width: width/2, height: width/2))
        return p
    }
}

#Preview {
    AnalogClockView(date: Date())
        .padding()
        .frame(width: 250, height: 250)
}
