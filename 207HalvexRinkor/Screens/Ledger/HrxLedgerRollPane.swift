import SwiftUI

struct HrxLedgerRollPane: View {
    @EnvironmentObject private var vault: HrxRinkVault
    @State private var query = ""

    private var visible: [HrxGlideSession] {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !text.isEmpty else { return vault.sessions }
        return vault.sessions.filter {
            $0.rinkLabel.lowercased().contains(text) || $0.edgeFocus.lowercased().contains(text) || $0.iceNote.lowercased().contains(text)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Skate ledger")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.hrxInk)
                TextField("Search rink or edge", text: $query)
                    .font(.subheadline)
                    .padding(10)
                    .background(Color.white)
                    .overlay(Rectangle().stroke(Color.hrxInk.opacity(0.2), lineWidth: 1))
                NavigationLink {
                    HrxSessionInkPane()
                } label: {
                    Text("Write a skate by hand")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.hrxOnFill)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.hrxInk)
                        .overlay(alignment: .leading) {
                            Rectangle().fill(Color.hrxLine).frame(width: 6)
                        }
                }
                .buttonStyle(.plain)
                if visible.isEmpty {
                    Text(vault.sessions.isEmpty ? "No skates yet. Use the lap dial or write one here." : "Nothing matches that search.")
                        .font(.footnote)
                        .foregroundColor(.hrxMuted)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ForEach(visible) { session in
                        NavigationLink {
                            HrxSessionInkPane(existingId: session.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.rinkLabel)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(.hrxInk)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(HrxDayStamp.medium(session.startedAt))
                                    .font(.caption)
                                    .foregroundColor(.hrxAccent)
                                Text("\(session.lapTotal) laps · \(session.minuteSpan) min · \(session.edgeFocus) · \(session.iceFace)")
                                    .font(.caption)
                                    .foregroundColor(.hrxMuted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(alignment: .leading) {
                                Capsule().fill(Color.hrxAccent).frame(width: 5).padding(.vertical, 10)
                            }
                            .shadow(color: Color.hrxPrimary.opacity(0.1), radius: 6, y: 3)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("Delete", role: .destructive) { vault.hrxDropSession(session.id) }
                        }
                    }
                }
            }
            .padding(16)
        }
        .hrxFoldInkOnTap()
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Sessions")
        .navigationBarTitleDisplayMode(.inline)
        .task { _ = HrxLedgerSalt.hrxGlaze(visible.count) }
    }
}

enum HrxLedgerSalt {
    static func hrxGlaze(_ count: Int) -> Double {
        var acc = Double(count) + 0.5
        var spin = 0
        repeat {
            acc = acc * 1.07 - Double(spin) * 0.1
            spin += 1
        } while spin < 6
        return acc
    }

    static func hrxMirrors(_ seed: Double) -> [Double] {
        var row = [seed]
        var index = 0
        while index < 5 {
            row.append(row[index] * -0.4 + Double(index))
            index += 1
        }
        return row
    }
}
