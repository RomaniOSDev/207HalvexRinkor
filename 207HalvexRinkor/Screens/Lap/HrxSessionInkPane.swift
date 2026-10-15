import SwiftUI

struct HrxSessionInkPane: View {
    var existingId: UUID? = nil
    var seededLaps: Int = 0
    var seededMinutes: Int = 20
    var seededEdge: String = "Forward edges"

    @EnvironmentObject private var vault: HrxRinkVault
    @Environment(\.dismiss) private var dismiss
    @State private var rinkLabel = ""
    @State private var laps = 0
    @State private var minutes = 20
    @State private var edgeFocus = "Forward edges"
    @State private var balanceMark = 3
    @State private var iceNote = ""
    @State private var iceFace = HrxIceFace.fresh.rawValue
    @State private var showFault = false
    @State private var loaded = false
    @State private var recordNote: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HrxFramedStill(name: "HrxBladeClose", height: 120)
                field("Rink", text: $rinkLabel)
                Stepper(value: $laps, in: 0...200) {
                    Text("Laps \(laps)")
                        .foregroundColor(.hrxInk)
                }
                Stepper(value: $minutes, in: 1...240, step: 1) {
                    Text("Minutes \(minutes)")
                        .foregroundColor(.hrxInk)
                }
                Text("Edge focus")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.hrxMuted)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(HrxEdgeCatalog.focuses, id: \.self) { item in
                            Button(item) { edgeFocus = item }
                                .font(.caption.weight(.bold))
                                .foregroundColor(edgeFocus == item ? .hrxOnFill : .hrxPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(edgeFocus == item ? Color.hrxAccent : Color.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                Stepper(value: $balanceMark, in: 1...5) {
                    Text("Balance feel \(balanceMark) of 5")
                        .foregroundColor(.hrxInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text("Ice")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.hrxMuted)
                HStack(spacing: 8) {
                    ForEach(HrxIceFace.allCases) { face in
                        Button(face.rawValue) { iceFace = face.rawValue }
                            .font(.caption.weight(.heavy))
                            .foregroundColor(iceFace == face.rawValue ? .hrxOnFill : .hrxPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(iceFace == face.rawValue ? Color.hrxAccent : Color.white)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(face == .chopped ? Color.hrxMuted : (face == .soft ? Color.hrxAccent : Color.hrxPrimary))
                                    .frame(height: 3)
                            }
                    }
                }
                Text(markLine)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.hrxLine)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Ice note")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.hrxMuted)
                TextField("How the ice and the glide felt", text: $iceNote, axis: .vertical)
                    .font(.subheadline)
                    .padding(10)
                    .background(Color.hrxAccent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                HrxFillButton(title: existingId == nil ? "Keep this skate" : "Update skate") {
                    hrxSave()
                }
            }
            .padding(16)
        }
        .hrxFoldInkOnTap()
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(existingId == nil ? "Save skate" : "Edit skate")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: hrxLoad)
        .alert("Add the rink", isPresented: $showFault) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Name the rink so this skate is easy to find later.")
        }
        .alert("Pace mark", isPresented: Binding(get: { recordNote != nil }, set: { if !$0 { recordNote = nil } })) {
            Button("OK") {
                recordNote = nil
                dismiss()
            }
        } message: {
            Text(recordNote ?? "")
        }
    }

    private var markLine: String {
        if let prior = HrxPaceBook.bestSeconds(edge: edgeFocus, sessions: vault.sessions, excluding: existingId) {
            return "Mark on this edge \(HrxPaceBook.clock(prior))"
        }
        return "No pace mark on this edge yet"
    }

    private func field(_ caption: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(caption)
                .font(.caption.weight(.bold))
                .foregroundColor(.hrxMuted)
            TextField(caption, text: text)
                .font(.subheadline)
                .padding(10)
                .background(Color.hrxAccent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func hrxLoad() {
        guard !loaded else { return }
        loaded = true
        if let existingId, let session = vault.hrxSession(existingId) {
            rinkLabel = session.rinkLabel
            laps = session.lapTotal
            minutes = session.minuteSpan
            edgeFocus = session.edgeFocus
            balanceMark = session.balanceMark
            iceNote = session.iceNote
            iceFace = session.iceFace
        } else {
            rinkLabel = vault.homeRink
            laps = seededLaps
            minutes = max(1, seededMinutes)
            edgeFocus = seededEdge
            iceFace = HrxIceFace.fresh.rawValue
        }
    }

    private func hrxSave() {
        let spot = rinkLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if spot.isEmpty {
            showFault = true
            return
        }
        let prior = existingId.flatMap { vault.hrxSession($0) }
        let session = HrxGlideSession(
            id: existingId ?? UUID(),
            rinkLabel: spot,
            startedAt: prior?.startedAt ?? Date(),
            lapTotal: laps,
            minuteSpan: minutes,
            edgeFocus: edgeFocus,
            balanceMark: balanceMark,
            iceNote: iceNote.trimmingCharacters(in: .whitespacesAndNewlines),
            iceFace: iceFace
        )
        let note = HrxPaceBook.beatNote(session: session, among: vault.sessions)
        vault.hrxUpsertSession(session)
        if let note {
            recordNote = note
        } else {
            dismiss()
        }
    }
}
