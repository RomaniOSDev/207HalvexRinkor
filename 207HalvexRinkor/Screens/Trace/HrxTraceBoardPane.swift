import Charts
import SwiftUI

struct HrxTraceBoardPane: View {
    @EnvironmentObject private var vault: HrxRinkVault

    private var pulses: [HrxDayPulse] { HrxGlideMath.pulses(sessions: vault.sessions) }
    private var slices: [HrxEdgeSlice] { HrxGlideMath.edgeSlices(sessions: vault.sessions) }
    private var lapPeak: Int { max(pulses.map(\.laps).max() ?? 0, 4) }
    private var minutePeak: Int { max(pulses.map(\.minutes).max() ?? 0, 20) }
    private var edgePeak: Int { max(slices.map(\.laps).max() ?? 0, 4) }
    private var icePeak: Int { max(pulses.map { $0.fresh + $0.soft + $0.chopped }.max() ?? 0, 1) }
    private var mirror: HrxHourMirror { HrxGlideMath.hourMirror(sessions: vault.sessions) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("TRACE")
                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                    .foregroundColor(.hrxLine)
                Text("Seven days on the sheet")
                    .font(.title2.weight(.heavy))
                    .foregroundColor(.hrxInk)

                HStack(spacing: 8) {
                    tally("Laps", "\(pulses.reduce(0) { $0 + $1.laps })")
                    tally("Pace", HrxGlideMath.paceClock(sessions: vault.sessions))
                    tally("Index", "\(HrxGlideMath.glideIndex(sessions: vault.sessions))")
                }

                Text(HrxGlideMath.biasLine(sessions: vault.sessions))
                    .font(.subheadline)
                    .foregroundColor(.hrxInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.9))
                    .overlay(alignment: .leading) {
                        Rectangle().fill(Color.hrxLine).frame(width: 5)
                    }

                board("Laps by day") {
                    Chart(pulses) { pulse in
                        BarMark(
                            x: .value("Day", pulse.label),
                            y: .value("Laps", pulse.laps)
                        )
                        .foregroundStyle(Color.hrxBlueLine)
                    }
                    .chartYScale(domain: 0...lapPeak)
                    .frame(height: 180)
                }

                board("Minutes by day") {
                    Chart(pulses) { pulse in
                        LineMark(
                            x: .value("Day", pulse.label),
                            y: .value("Minutes", pulse.minutes)
                        )
                        .foregroundStyle(Color.hrxLine)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        PointMark(
                            x: .value("Day", pulse.label),
                            y: .value("Minutes", pulse.minutes)
                        )
                        .foregroundStyle(Color.hrxInk)
                    }
                    .chartYScale(domain: 0...minutePeak)
                    .frame(height: 180)
                }

                HStack(spacing: 8) {
                    tally("This hour", "\(mirror.nowLaps)")
                    tally("Last week", "\(mirror.thenLaps)")
                }
                Text(mirror.line)
                    .font(.subheadline)
                    .foregroundColor(.hrxInk)
                    .fixedSize(horizontal: false, vertical: true)

                board("Ice by day") {
                    Chart(pulses) { pulse in
                        BarMark(x: .value("Day", pulse.label), y: .value("Fresh", pulse.fresh))
                            .foregroundStyle(Color.hrxBlueLine)
                        BarMark(x: .value("Day", pulse.label), y: .value("Soft", pulse.soft))
                            .foregroundStyle(Color.hrxAccent)
                        BarMark(x: .value("Day", pulse.label), y: .value("Chopped", pulse.chopped))
                            .foregroundStyle(Color.hrxMuted)
                    }
                    .chartYScale(domain: 0...icePeak)
                    .frame(height: 180)
                    HStack(spacing: 12) {
                        iceKey("Fresh", .hrxBlueLine)
                        iceKey("Soft", .hrxAccent)
                        iceKey("Chopped", .hrxMuted)
                    }
                }

                board("Laps by edge") {
                    Chart(slices) { slice in
                        BarMark(
                            x: .value("Laps", slice.laps),
                            y: .value("Edge", slice.title)
                        )
                        .foregroundStyle(Color.hrxPrimary)
                    }
                    .chartXScale(domain: 0...edgePeak)
                    .frame(height: 220)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("PACE MARKS")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.hrxBlueLine)
                    ForEach(HrxEdgeCatalog.focuses, id: \.self) { edge in
                        HStack {
                            Text(edge)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.hrxInk)
                            Spacer()
                            if HrxPaceBook.latestHoldsMark(edge: edge, sessions: vault.sessions) {
                                Text("MARK")
                                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                    .foregroundColor(.hrxLine)
                            }
                            Text(HrxPaceBook.bestSeconds(edge: edge, sessions: vault.sessions).map(HrxPaceBook.clock) ?? "—")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundColor(.hrxInk)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.92))
                .overlay(Rectangle().stroke(Color.hrxInk.opacity(0.15), lineWidth: 1))

                NavigationLink {
                    HrxWeekGlidePane()
                } label: {
                    Text("Open the day strip")
                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                        .foregroundColor(.hrxInk)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
        }
        .navigationBarHidden(true)
    }

    private func tally(_ caption: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(caption.uppercased())
                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                .foregroundColor(.hrxMuted)
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.hrxInk)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.9))
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.hrxBlueLine).frame(height: 3)
        }
    }

    private func iceKey(_ title: String, _ color: Color) -> some View {
        HStack(spacing: 4) {
            Rectangle().fill(color).frame(width: 10, height: 10)
            Text(title)
                .font(.caption2.weight(.heavy))
                .foregroundColor(.hrxMuted)
        }
    }

    private func board<Content: View>(_ title: String, @ViewBuilder chart: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundColor(.hrxBlueLine)
            chart()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.92))
        .overlay(Rectangle().stroke(Color.hrxInk.opacity(0.15), lineWidth: 1))
    }
}
