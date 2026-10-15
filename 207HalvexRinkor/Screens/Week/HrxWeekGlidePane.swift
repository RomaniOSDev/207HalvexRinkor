import SwiftUI

struct HrxWeekGlidePane: View {
    @EnvironmentObject private var vault: HrxRinkVault

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Week on the ice")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.hrxInk)
                Text("Each row is one day. The bar grows with laps.")
                    .font(.footnote)
                    .foregroundColor(.hrxMuted)
                    .fixedSize(horizontal: false, vertical: true)
                HrxFramedStill(name: "HrxArenaGlow", height: 120)
                let rows = vault.hrxWeekRows()
                let peak = max(rows.map(\.laps).max() ?? 1, 1)
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(row.label)
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.hrxPrimary)
                                .frame(width: 36, alignment: .leading)
                            Text("\(row.laps) laps · \(row.minutes) min")
                                .font(.caption)
                                .foregroundColor(.hrxMuted)
                            Spacer()
                        }
                        GeometryReader { proxy in
                            Capsule()
                                .fill(Color.hrxMuted.opacity(0.25))
                                .overlay(alignment: .leading) {
                                    Capsule()
                                        .fill(LinearGradient(colors: [Color.hrxPrimary, Color.hrxAccent], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: max(8, proxy.size.width * CGFloat(row.laps) / CGFloat(peak)))
                                }
                        }
                        .frame(height: 10)
                    }
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.hrxPrimary.opacity(0.08), radius: 5, y: 3)
                }
                let laps = rows.reduce(0) { $0 + $1.laps }
                let minutes = rows.reduce(0) { $0 + $1.minutes }
                Text("\(laps) laps and \(minutes) minutes across these seven days.")
                    .font(.subheadline)
                    .foregroundColor(.hrxPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
        }
        .hrxSheetBackdrop("HrxArenaGlow", veil: 0)
        .navigationTitle("Week")
        .navigationBarTitleDisplayMode(.inline)
    }
}
