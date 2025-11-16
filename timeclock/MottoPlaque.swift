import SwiftUI

struct MottoPlaque: View {
    var text: String = "EVERY SECOND COUNTS"
    var body: some View {
        Text(text)
            .font(.system(size: 28, weight: .semibold, design: .rounded))
            .kerning(2)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(red: 0.05, green: 0.25, blue: 0.55))
                    .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
            )
    }
}

#Preview {
    MottoPlaque()
        .padding()
}
