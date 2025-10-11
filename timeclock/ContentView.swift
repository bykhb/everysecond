import SwiftUI

struct ContentView: View {
    @StateObject private var timeTracker = TimeTracker()
    
    var body: some View {
        VStack(spacing: 40) {
            // Title
            Text("Time Clock")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Time Display
            VStack(spacing: 10) {
                Picker("Mode", selection: $timeTracker.displayMode) {
                    Text("Stopwatch").tag(TimeDisplayMode.stopwatch)
                    Text("Clock").tag(TimeDisplayMode.clock)
                }
                .pickerStyle(.segmented)
                .onChange(of: timeTracker.displayMode) { _, newMode in
                    timeTracker.setDisplayMode(newMode)
                }
                
                if timeTracker.displayMode == .clock {
                    VStack(spacing: 16) {
                        AnalogClockView(date: Date())
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                        LEDClockView(date: Date(), timeFormat: "HH:mm:ss", fontSize: 92)
                            .frame(maxWidth: .infinity)
                        MottoPlaque()
                            .padding(.top, 4)
                    }
                } else {
                    Text(timeTracker.displayString)
                        .font(.system(size: 48, weight: .light, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.secondary.opacity(0.15))
                        )
                }
                
                Text(timeTracker.isRunning ? "Running" : "Stopped")
                    .font(.headline)
                    .foregroundColor(timeTracker.isRunning ? .green : .red)
            }
            
            if timeTracker.displayMode == .stopwatch {
                HStack(spacing: 30) {
                    // Start/Stop Button
                    Button(action: {
                        if timeTracker.isRunning {
                            timeTracker.stopTimer()
                        } else {
                            timeTracker.startTimer()
                        }
                    }) {
                        HStack {
                            Image(systemName: timeTracker.isRunning ? "stop.fill" : "play.fill")
                            Text(timeTracker.isRunning ? "Stop" : "Start")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(timeTracker.isRunning ? Color.red : Color.green)
                        )
                    }
                    
                    // Reset Button
                    Button(action: {
                        timeTracker.resetTimer()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.blue)
                        )
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear { timeTracker.setDisplayMode(timeTracker.displayMode) }
        .background(Color.clear)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
