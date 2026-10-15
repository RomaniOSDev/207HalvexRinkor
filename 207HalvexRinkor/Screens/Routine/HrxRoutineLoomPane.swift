import SwiftUI

struct HrxRoutineLoomPane: View {
    @EnvironmentObject private var vault: HrxRinkVault
    @State private var title = ""
    @State private var note = ""
    @State private var picked: Set<String> = []
    @State private var showFault = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Routine loom")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.hrxInk)
                Text("Build a short sequence from the skill board, then skate through it.")
                    .font(.footnote)
                    .foregroundColor(.hrxMuted)
                    .fixedSize(horizontal: false, vertical: true)

                TextField("Routine name", text: $title)
                    .font(.subheadline)
                    .padding(10)
                    .background(Color.white)
                    .overlay(Rectangle().stroke(Color.hrxInk.opacity(0.2), lineWidth: 1))
                TextField("Reminder for yourself", text: $note, axis: .vertical)
                    .font(.subheadline)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                ForEach(HrxEdgeCatalog.skills) { skill in
                    Button {
                        if picked.contains(skill.id) { picked.remove(skill.id) } else { picked.insert(skill.id) }
                    } label: {
                        HStack {
                            Image(systemName: picked.contains(skill.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.hrxPrimary)
                            Text(skill.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.hrxInk)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        .padding(10)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                HrxFillButton(title: "Save routine") { hrxSave() }

                if vault.routines.isEmpty {
                    Text("No routines yet.")
                        .font(.footnote)
                        .foregroundColor(.hrxMuted)
                } else {
                    ForEach(vault.routines) { strand in
                        HStack {
                            NavigationLink {
                                HrxRoutineStridePane(routineId: strand.id)
                            } label: {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(strand.title)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundColor(.hrxInk)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text("\(strand.drillIds.count) steps")
                                        .font(.caption)
                                        .foregroundColor(.hrxAccent)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            Button {
                                vault.hrxDropRoutine(strand.id)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.hrxPrimary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .background(
                            LinearGradient(colors: [Color.white, Color.hrxAccent.opacity(0.12)], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.hrxPrimary.opacity(0.1), radius: 5, y: 3)
                    }
                }
            }
            .padding(16)
        }
        .hrxFoldInkOnTap()
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Routines")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Name and steps", isPresented: $showFault) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Add a name and at least one skill before saving.")
        }
    }

    private func hrxSave() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || picked.isEmpty {
            showFault = true
            return
        }
        let ordered = HrxEdgeCatalog.skills.map(\.id).filter { picked.contains($0) }
        vault.hrxUpsertRoutine(HrxRoutineStrand(id: UUID(), title: trimmed, drillIds: ordered, note: note.trimmingCharacters(in: .whitespacesAndNewlines)))
        title = ""
        note = ""
        picked = []
    }
}

struct HrxRoutineStridePane: View {
    let routineId: UUID
    @EnvironmentObject private var vault: HrxRinkVault
    @State private var step = 0
    @State private var doneCount = 0

    private var strand: HrxRoutineStrand? { vault.routines.first { $0.id == routineId } }

    var body: some View {
        ScrollView {
            if let strand {
                let drills = strand.drillIds.compactMap { HrxEdgeCatalog.skill($0) }
                VStack(alignment: .leading, spacing: 14) {
                    Text(strand.title)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.hrxInk)
                        .fixedSize(horizontal: false, vertical: true)
                    if !strand.note.isEmpty {
                        Text(strand.note)
                            .font(.subheadline)
                            .foregroundColor(.hrxMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if drills.isEmpty {
                        Text("This routine has no steps left.")
                            .foregroundColor(.hrxMuted)
                    } else if step >= drills.count {
                        HrxFramedStill(name: "HrxOvalIce", height: 140)
                        Text("Sequence complete. \(doneCount) steps were counted on today's reps.")
                            .font(.body)
                            .foregroundColor(.hrxPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        HrxQuietButton(title: "Skate it again") {
                            step = 0
                            doneCount = 0
                        }
                    } else {
                        let skill = drills[step]
                        Text("Step \(step + 1) of \(drills.count)")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.hrxAccent)
                        Text(skill.title)
                            .font(.title2.weight(.bold))
                            .foregroundColor(.hrxInk)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(skill.detail)
                            .font(.body)
                            .foregroundColor(.hrxPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(skill.cue)
                            .font(.subheadline)
                            .foregroundColor(.hrxMuted)
                            .fixedSize(horizontal: false, vertical: true)
                        HrxFillButton(title: "Mark this step") {
                            vault.hrxSetReps(drillId: skill.id, reps: vault.hrxRepsToday(for: skill.id) + 1)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                doneCount += 1
                                step += 1
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Stride")
        .navigationBarTitleDisplayMode(.inline)
    }
}
