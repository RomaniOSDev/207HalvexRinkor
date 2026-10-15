import SwiftUI

struct HrxLapDialPane: View {
    @EnvironmentObject private var vault: HrxRinkVault
    @State private var laps = 0
    @State private var elapsed = 0
    @State private var ticking = false
    @State private var bump = false
    @State private var edgeFocus = "Forward edges"
    @State private var openInk = false
    @State private var showNeed = false
    @State private var restLeft = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HrxFramedStill(name: "HrxGlideMotion", height: 130)
                Text(restLeft > 0 ? "Rest \(hrxClock(restLeft))" : hrxClock(elapsed))
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(restLeft > 0 ? .hrxLine : .hrxAccent)
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(colors: [Color.white, Color.hrxAccent.opacity(0.25)], center: .center, startRadius: 10, endRadius: 120)
                        )
                        .shadow(color: Color.hrxPrimary.opacity(0.2), radius: 12, y: 6)
                    Text("\(laps)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.hrxPrimary)
                        .scaleEffect(bump ? 1.08 : 1)
                }
                .frame(width: 190, height: 190)

                HrxFillButton(title: "Add a lap") {
                    laps += 1
                    if !ticking { ticking = true }
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) { bump = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { bump = false }
                    }
                }
                HStack(spacing: 8) {
                    HrxQuietButton(title: ticking ? "Pause" : "Start timer") {
                        if restLeft == 0 { ticking.toggle() }
                    }
                    HrxQuietButton(title: "Undo lap") { laps = max(0, laps - 1) }
                }
                if restLeft > 0 {
                    HrxQuietButton(title: "Skip rest") { restLeft = 0 }
                } else {
                    HrxQuietButton(title: "Rest 45s") {
                        ticking = false
                        restLeft = 45
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Edge focus")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.hrxMuted)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(HrxEdgeCatalog.focuses, id: \.self) { item in
                                Button(item) {
                                    guard item != edgeFocus else { return }
                                    edgeFocus = item
                                    ticking = false
                                    restLeft = 45
                                }
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(edgeFocus == item ? .hrxOnFill : .hrxPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(edgeFocus == item ? Color.hrxAccent : Color.white)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.hrxPrimary.opacity(0.12), radius: 3, y: 2)
                            }
                        }
                    }
                }
                Button {
                    if laps == 0 && elapsed < 30 {
                        showNeed = true
                    } else {
                        openInk = true
                    }
                } label: {
                    Text("Save this skate")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.hrxOnFill)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.hrxPrimary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                Text("Add a lap or skate for half a minute, then save.")
                    .font(.caption)
                    .foregroundColor(.hrxMuted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
        }
        .navigationTitle("Lap dial")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if restLeft > 0 {
                restLeft -= 1
            } else if ticking {
                elapsed += 1
            }
        }
        .onDisappear { ticking = false }
        .navigationDestination(isPresented: $openInk) {
            HrxSessionInkPane(seededLaps: laps, seededMinutes: max(elapsed / 60, 1), seededEdge: edgeFocus)
        }
        .alert("Keep skating", isPresented: $showNeed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Add a lap or let the timer pass half a minute, then save.")
        }
    }

    private func hrxClock(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
