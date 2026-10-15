import StoreKit
import SwiftUI

struct HrxPreferencePane: View {
    @EnvironmentObject private var vault: HrxRinkVault
    @State private var rinkDraft = ""
    @State private var armedClear = false
    @State private var loaded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("BOARD")
                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                    .foregroundColor(.hrxLine)
                Text("Rink board")
                    .font(.title2.weight(.heavy))
                    .foregroundColor(.hrxInk)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Home rink")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.hrxMuted)
                    TextField("Rink name", text: $rinkDraft)
                        .font(.subheadline)
                        .padding(10)
                        .background(Color.white)
                        .overlay(Rectangle().stroke(Color.hrxInk.opacity(0.25), lineWidth: 1))
                    HrxFillButton(title: "Save rink name") {
                        vault.hrxSetHomeRink(rinkDraft)
                        rinkDraft = vault.homeRink
                    }
                    Text("Rough end")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.hrxMuted)
                    HStack(spacing: 8) {
                        ForEach(HrxRinkEnd.allCases) { end in
                            Button(end.rawValue) { vault.hrxSetRoughEnd(end.rawValue) }
                                .font(.caption2.weight(.heavy))
                                .foregroundColor(vault.roughEnd == end.rawValue ? .hrxOnFill : .hrxInk)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(vault.roughEnd == end.rawValue ? Color.hrxInk : Color.white)
                                .overlay(Rectangle().stroke(Color.hrxInk.opacity(0.2), lineWidth: 1))
                        }
                    }
                    Stepper(value: Binding(get: { vault.lapGoal }, set: { vault.hrxSetLapGoal($0) }), in: 1...80) {
                        Text("Daily lap goal \(vault.lapGoal)")
                            .foregroundColor(.hrxInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(12)
                .background(Color.white)
                .overlay(Rectangle().stroke(Color.hrxLine, lineWidth: 2))

                HStack(spacing: 8) {
                    hrxStamp("Rate Us", fill: Color.hrxPrimary, action: rateApp)
                    hrxStamp("Privacy", fill: Color.hrxAccent, action: { hrxOpen(HrxParchmentGate.privacyLeaf) })
                    hrxStamp("Terms", fill: Color.hrxInk, action: { hrxOpen(HrxParchmentGate.termsLeaf) })
                }

                Button("See the ice boards again") { vault.hrxReplayIntro() }
                    .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    .foregroundColor(.hrxPrimary)

                if armedClear {
                    Text("Skates, routines, reps, and notes leave this phone.")
                        .font(.footnote)
                        .foregroundColor(.hrxMuted)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack {
                        Button("Wipe the sheet") { vault.hrxClearRink(); armedClear = false }
                            .font(.caption.weight(.bold))
                            .foregroundColor(.hrxOnFill)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(Color.hrxInk)
                        Button("Keep the sheet") { armedClear = false }
                            .font(.caption.weight(.bold))
                            .foregroundColor(.hrxInk)
                    }
                } else {
                    Button("Clear skates and notes") { armedClear = true }
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.hrxAccent)
                }

                HrxFramedStill(name: "HrxOvalIce", height: 90)
            }
            .padding(16)
        }
        .hrxFoldInkOnTap()
        .scrollDismissesKeyboard(.interactively)
        .navigationBarHidden(true)
    }

    private func hrxStamp(_ title: String, fill: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.heavy))
                .foregroundColor(.hrxOnFill)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 64)
                .padding(6)
                .background(fill)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(Color.hrxLine).frame(height: 4)
                }
        }
        .buttonStyle(.plain)
    }

    private func hrxOpen(_ leaf: String) {
        if let url = URL(string: leaf) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
