import SwiftUI

struct HrxIceNotePane: View {
    @EnvironmentObject private var vault: HrxRinkVault
    @State private var rink = ""
    @State private var bodyText = ""
    @State private var feel = 3
    @State private var editingId: UUID?
    @State private var showFault = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HrxFramedStill(name: "HrxArenaGlow", height: 110)
                Text(editingId == nil ? "New ice note" : "Edit ice note")
                    .font(.headline)
                    .foregroundColor(.hrxInk)
                TextField("Rink", text: $rink)
                    .font(.subheadline)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                TextField("What the session felt like", text: $bodyText, axis: .vertical)
                    .font(.subheadline)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                Stepper(value: $feel, in: 1...5) {
                    Text("Feel \(feel) of 5")
                        .foregroundColor(.hrxInk)
                }
                HrxFillButton(title: editingId == nil ? "Save note" : "Update note") { hrxSave() }
                if editingId != nil {
                    HrxQuietButton(title: "Cancel edit") { hrxReset() }
                }
                ForEach(vault.notes) { jot in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(jot.rinkLabel)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.hrxInk)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(HrxDayStamp.medium(jot.writtenAt))
                            .font(.caption)
                            .foregroundColor(.hrxAccent)
                        Text(jot.body)
                            .font(.footnote)
                            .foregroundColor(.hrxPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Feel \(jot.feel) of 5")
                            .font(.caption)
                            .foregroundColor(.hrxMuted)
                        HStack {
                            Button("Edit") { hrxLoad(jot) }
                                .font(.caption.weight(.bold))
                                .foregroundColor(.hrxPrimary)
                            Button("Delete") { vault.hrxDropNote(jot.id) }
                                .font(.caption.weight(.bold))
                                .foregroundColor(.hrxAccent)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.white.opacity(0.94))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color.hrxPrimary.opacity(0.1), radius: 5, y: 3)
                }
            }
            .padding(16)
        }
        .hrxFoldInkOnTap()
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Ice notes")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if rink.isEmpty { rink = vault.homeRink }
        }
        .alert("Write a note", isPresented: $showFault) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Add a rink and a few words before saving.")
        }
    }

    private func hrxSave() {
        let spot = rink.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        if spot.isEmpty || words.isEmpty {
            showFault = true
            return
        }
        let prior = editingId.flatMap { id in vault.notes.first { $0.id == id } }
        vault.hrxUpsertNote(HrxIceJot(
            id: editingId ?? UUID(),
            rinkLabel: spot,
            writtenAt: prior?.writtenAt ?? Date(),
            body: words,
            feel: feel
        ))
        hrxReset()
    }

    private func hrxLoad(_ jot: HrxIceJot) {
        editingId = jot.id
        rink = jot.rinkLabel
        bodyText = jot.body
        feel = jot.feel
    }

    private func hrxReset() {
        editingId = nil
        rink = vault.homeRink
        bodyText = ""
        feel = 3
    }
}
