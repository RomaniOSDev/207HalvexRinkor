import SwiftUI

struct HrxSkillBoardPane: View {
    @EnvironmentObject private var vault: HrxRinkVault

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HrxFramedStill(name: "HrxBladeClose", height: 130)
                Text("Skill board")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.hrxInk)
                Text("Reps reset in the count each new day. The history of today stays on this phone.")
                    .font(.footnote)
                    .foregroundColor(.hrxMuted)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(HrxEdgeCatalog.skills) { skill in
                    NavigationLink {
                        HrxSkillLeafPane(drillId: skill.id)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(skill.title)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(.hrxInk)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(skill.cue)
                                    .font(.caption)
                                    .foregroundColor(.hrxPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 8)
                            if skill.id == "onefoot" {
                                Text("L\(vault.hrxRepsToday(for: HrxBladeSide.left)) R\(vault.hrxRepsToday(for: HrxBladeSide.right))")
                                    .font(.caption.weight(.heavy))
                                    .foregroundColor(.hrxOnFill)
                                    .padding(.horizontal, 8)
                                    .frame(height: 42)
                                    .background(Color.hrxInk)
                                    .overlay(alignment: .bottom) {
                                        Rectangle().fill(Color.hrxLine).frame(height: 3)
                                    }
                            } else {
                                Text("\(vault.hrxRepsToday(for: skill.id))")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.hrxOnFill)
                                    .frame(width: 42, height: 42)
                                    .background(Color.hrxInk)
                                    .overlay(alignment: .bottom) {
                                        Rectangle().fill(Color.hrxLine).frame(height: 3)
                                    }
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .overlay(Rectangle().stroke(Color.hrxInk.opacity(0.12), lineWidth: 1))
                        .shadow(color: Color.hrxPrimary.opacity(0.12), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .navigationTitle("Skills")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HrxSkillLeafPane: View {
    let drillId: String
    @EnvironmentObject private var vault: HrxRinkVault

    private var skill: HrxSkillLeaf? { HrxEdgeCatalog.skill(drillId) }

    var body: some View {
        ScrollView {
            if let skill {
                VStack(alignment: .leading, spacing: 14) {
                    HrxFramedStill(name: "HrxGlideMotion", height: 150)
                    Text(skill.title)
                        .font(.title3.weight(.bold))
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
                    if drillId == "onefoot" {
                        HStack(spacing: 12) {
                            bladeColumn("Left", HrxBladeSide.left)
                            bladeColumn("Right", HrxBladeSide.right)
                        }
                    } else {
                    HStack {
                        Button {
                            vault.hrxSetReps(drillId: drillId, reps: vault.hrxRepsToday(for: drillId) - 1)
                        } label: {
                            Image(systemName: "minus")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.hrxOnFill)
                                .frame(width: 54, height: 54)
                                .background(Circle().fill(Color.hrxAccent))
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        VStack {
                            Text("\(vault.hrxRepsToday(for: drillId))")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.hrxPrimary)
                            Text("reps today")
                                .font(.caption)
                                .foregroundColor(.hrxMuted)
                        }
                        Spacer()
                        Button {
                            vault.hrxSetReps(drillId: drillId, reps: vault.hrxRepsToday(for: drillId) + 1)
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.hrxOnFill)
                                .frame(width: 54, height: 54)
                                .background(Circle().fill(Color.hrxPrimary))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Skill")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bladeColumn(_ title: String, _ side: String) -> some View {
        VStack(spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundColor(.hrxLine)
            Text("\(vault.hrxRepsToday(for: side))")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.hrxInk)
            HStack(spacing: 8) {
                Button {
                    vault.hrxSetReps(drillId: side, reps: vault.hrxRepsToday(for: side) - 1)
                } label: {
                    Text("−")
                        .font(.title3.weight(.heavy))
                        .foregroundColor(.hrxOnFill)
                        .frame(width: 44, height: 36)
                        .background(Color.hrxAccent)
                }
                .buttonStyle(.plain)
                Button {
                    vault.hrxSetReps(drillId: side, reps: vault.hrxRepsToday(for: side) + 1)
                } label: {
                    Text("+")
                        .font(.title3.weight(.heavy))
                        .foregroundColor(.hrxOnFill)
                        .frame(width: 44, height: 36)
                        .background(Color.hrxInk)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.white.opacity(0.92))
        .overlay(Rectangle().stroke(Color.hrxInk.opacity(0.12), lineWidth: 1))
    }
}
