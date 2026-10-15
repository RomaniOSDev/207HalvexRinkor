import SwiftUI

struct HrxDawnOvalPane: View {
    @EnvironmentObject private var vault: HrxRinkVault

    private var focus: HrxSkillLeaf { HrxEdgeCatalog.packet(for: Date()) }
    private var ribbon: CGFloat { HrxOvalDraft.ribbon(laps: vault.hrxTodayLaps(), goal: vault.lapGoal) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SHEET")
                            .font(.system(size: 12, weight: .heavy, design: .monospaced))
                            .foregroundColor(.hrxLine)
                        Text("Oval today")
                            .font(.title2.weight(.heavy))
                            .foregroundColor(.hrxInk)
                        Text("\(vault.hrxStreakSpan()) day streak · \(vault.homeRink)")
                            .font(.subheadline)
                            .foregroundColor(.hrxAccent)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(vault.roughEnd == HrxRinkEnd.even.rawValue ? "Both ends skate even" : "Rough end · \(vault.roughEnd)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.hrxLine)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    NavigationLink {
                        HrxPreferencePane()
                    } label: {
                        Text("SET")
                            .font(.system(size: 12, weight: .heavy, design: .monospaced))
                            .foregroundColor(.hrxOnFill)
                            .frame(width: 46, height: 46)
                            .background(Color.hrxInk)
                            .overlay(alignment: .bottom) {
                                Rectangle().fill(Color.hrxLine).frame(height: 4)
                            }
                    }
                }

                HrxIceOval(progress: ribbon, laps: vault.hrxTodayLaps(), goal: vault.lapGoal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("EDGE OF THE DAY")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.hrxLine)
                    Text(focus.title)
                        .font(.headline.weight(.heavy))
                        .foregroundColor(.hrxInk)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(focus.cue)
                        .font(.subheadline)
                        .foregroundColor(.hrxPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Button {
                        vault.hrxToggleFocus()
                    } label: {
                        Text(vault.hrxFocusDoneToday() ? "Marked for today" : "Mark this edge")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.hrxOnFill)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(vault.hrxFocusDoneToday() ? Color.hrxAccent : Color.hrxPrimary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.92))
                .overlay(alignment: .leading) {
                    Rectangle().fill(Color.hrxLine).frame(width: 5)
                }

                lane("Lap dial", "Tap each length as you glide", stripe: .hrxLine) { HrxLapDialPane() }
                lane("Skills", "Reps for the edges on the board", stripe: .hrxBlueLine) { HrxSkillBoardPane() }
                lane("Routines", "A short sequence you can repeat", stripe: .hrxPrimary) { HrxRoutineLoomPane() }
            }
            .padding(16)
        }
        .navigationBarHidden(true)
        .hrxSheetBackdrop("HrxOvalIce", veil: 0)
    }

    private func lane<Destination: View>(_ title: String, _ detail: String, stripe: Color, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 0) {
                Rectangle().fill(stripe).frame(width: 5)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(.hrxInk)
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.hrxMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                Spacer(minLength: 8)
                Text(">")
                    .font(.system(size: 16, weight: .heavy, design: .monospaced))
                    .foregroundColor(.hrxLine)
                    .padding(.trailing, 12)
            }
            .background(Color.white.opacity(0.9))
            .overlay(Rectangle().stroke(Color.hrxInk.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct HrxIceOval: View {
    var progress: CGFloat
    var laps: Int
    var goal: Int

    var body: some View {
        ZStack {
            Canvas { context, size in
                let rect = CGRect(x: 18, y: 16, width: size.width - 36, height: size.height - 32)
                let oval = Path(ellipseIn: rect)
                context.stroke(oval, with: .color(Color.hrxPrimary.opacity(0.35)), lineWidth: 8)
                var center = Path()
                center.move(to: CGPoint(x: rect.midX, y: rect.minY + 8))
                center.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - 8))
                context.stroke(center, with: .color(Color.hrxPrimary), lineWidth: 2)
                let face = oval.trimmedPath(from: 0, to: progress)
                context.stroke(face, with: .color(Color.hrxAccent), style: StrokeStyle(lineWidth: 5, lineCap: .square))
            }
            VStack(spacing: 0) {
                Text("\(laps)")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(.hrxInk)
                Text("of \(goal) · \(HrxOvalDraft.faceClock(laps: laps, goal: goal))%")
                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                    .foregroundColor(.hrxMuted)
            }
        }
        .frame(height: 168)
        .background(Color.white)
        .overlay(Rectangle().stroke(Color.hrxInk.opacity(0.18), lineWidth: 1))
    }
}
