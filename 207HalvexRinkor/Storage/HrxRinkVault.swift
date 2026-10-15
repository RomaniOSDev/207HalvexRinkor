import Foundation

struct HrxDiskEnvelope: Codable {
    var sessions: [HrxGlideSession]
    var repMarks: [HrxRepMark]
    var routines: [HrxRoutineStrand]
    var notes: [HrxIceJot]
    var visitDays: [String]
    var focusDoneDays: [String]
    var onboardingCleared: Bool
    var homeRink: String
    var lapGoal: Int
    var roughEnd: String

    init(sessions: [HrxGlideSession], repMarks: [HrxRepMark], routines: [HrxRoutineStrand], notes: [HrxIceJot], visitDays: [String], focusDoneDays: [String], onboardingCleared: Bool, homeRink: String, lapGoal: Int, roughEnd: String) {
        self.sessions = sessions
        self.repMarks = repMarks
        self.routines = routines
        self.notes = notes
        self.visitDays = visitDays
        self.focusDoneDays = focusDoneDays
        self.onboardingCleared = onboardingCleared
        self.homeRink = homeRink
        self.lapGoal = lapGoal
        self.roughEnd = roughEnd
    }

    init(from decoder: Decoder) throws {
        let box = try decoder.container(keyedBy: CodingKeys.self)
        sessions = try box.decode([HrxGlideSession].self, forKey: .sessions)
        repMarks = try box.decode([HrxRepMark].self, forKey: .repMarks)
        routines = try box.decode([HrxRoutineStrand].self, forKey: .routines)
        notes = try box.decode([HrxIceJot].self, forKey: .notes)
        visitDays = try box.decode([String].self, forKey: .visitDays)
        focusDoneDays = try box.decode([String].self, forKey: .focusDoneDays)
        onboardingCleared = try box.decode(Bool.self, forKey: .onboardingCleared)
        homeRink = try box.decode(String.self, forKey: .homeRink)
        lapGoal = try box.decode(Int.self, forKey: .lapGoal)
        roughEnd = try box.decodeIfPresent(String.self, forKey: .roughEnd) ?? HrxRinkEnd.even.rawValue
    }

    func encode(to encoder: Encoder) throws {
        var box = encoder.container(keyedBy: CodingKeys.self)
        try box.encode(sessions, forKey: .sessions)
        try box.encode(repMarks, forKey: .repMarks)
        try box.encode(routines, forKey: .routines)
        try box.encode(notes, forKey: .notes)
        try box.encode(visitDays, forKey: .visitDays)
        try box.encode(focusDoneDays, forKey: .focusDoneDays)
        try box.encode(onboardingCleared, forKey: .onboardingCleared)
        try box.encode(homeRink, forKey: .homeRink)
        try box.encode(lapGoal, forKey: .lapGoal)
        try box.encode(roughEnd, forKey: .roughEnd)
    }

    private enum CodingKeys: String, CodingKey {
        case sessions, repMarks, routines, notes, visitDays, focusDoneDays, onboardingCleared, homeRink, lapGoal, roughEnd
    }
}

final class HrxRinkVault: ObservableObject {
    @Published var sessions: [HrxGlideSession] = []
    @Published var repMarks: [HrxRepMark] = []
    @Published var routines: [HrxRoutineStrand] = []
    @Published var notes: [HrxIceJot] = []
    @Published var visitDays: [String] = []
    @Published var focusDoneDays: [String] = []
    @Published var onboardingCleared = false
    @Published var homeRink = "Home rink"
    @Published var lapGoal = 8
    @Published var roughEnd = HrxRinkEnd.even.rawValue

    private let fileURL: URL

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let folder = base.appendingPathComponent("HrxRinkVault", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        fileURL = folder.appendingPathComponent("rink-envelope.json")
        hrxBootFromDisk()
    }

    func hrxStampVisit() {
        let key = HrxDayStamp.key(Date())
        guard !visitDays.contains(key) else { return }
        visitDays.append(key)
        hrxFlushEnvelope()
    }

    func hrxStreakSpan() -> Int {
        let calendar = Calendar.current
        let logged = Set(visitDays.compactMap { HrxDayStamp.moment(from: $0) }.map { calendar.startOfDay(for: $0) })
        return hrxWalkIce(from: calendar.startOfDay(for: Date()), logged: logged, calendar: calendar, run: 0)
    }

    private func hrxWalkIce(from day: Date, logged: Set<Date>, calendar: Calendar, run: Int) -> Int {
        guard logged.contains(day), run < 500 else { return run }
        guard let earlier = calendar.date(byAdding: .day, value: -1, to: day) else { return run + 1 }
        return hrxWalkIce(from: earlier, logged: logged, calendar: calendar, run: run + 1)
    }

    func hrxTodayLaps() -> Int {
        sessions.filter { Calendar.current.isDateInToday($0.startedAt) }.reduce(0) { $0 + $1.lapTotal }
    }

    func hrxUpsertSession(_ session: HrxGlideSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.insert(session, at: 0)
        }
        sessions.sort { $0.startedAt > $1.startedAt }
        hrxFlushEnvelope()
    }

    func hrxDropSession(_ id: UUID) {
        sessions.removeAll { $0.id == id }
        hrxFlushEnvelope()
    }

    func hrxSession(_ id: UUID) -> HrxGlideSession? {
        sessions.first { $0.id == id }
    }

    func hrxRepsToday(for drillId: String) -> Int {
        let key = HrxDayStamp.key(Date())
        return repMarks.first { $0.dayKey == key && $0.drillId == drillId }?.reps ?? 0
    }

    func hrxSetReps(drillId: String, reps: Int) {
        let key = HrxDayStamp.key(Date())
        let markId = "\(key)-\(drillId)"
        if let index = repMarks.firstIndex(where: { $0.id == markId }) {
            repMarks[index].reps = max(0, reps)
        } else {
            repMarks.append(HrxRepMark(id: markId, dayKey: key, drillId: drillId, reps: max(0, reps)))
        }
        hrxFlushEnvelope()
    }

    func hrxUpsertRoutine(_ strand: HrxRoutineStrand) {
        if let index = routines.firstIndex(where: { $0.id == strand.id }) {
            routines[index] = strand
        } else {
            routines.insert(strand, at: 0)
        }
        hrxFlushEnvelope()
    }

    func hrxDropRoutine(_ id: UUID) {
        routines.removeAll { $0.id == id }
        hrxFlushEnvelope()
    }

    func hrxUpsertNote(_ jot: HrxIceJot) {
        if let index = notes.firstIndex(where: { $0.id == jot.id }) {
            notes[index] = jot
        } else {
            notes.insert(jot, at: 0)
        }
        notes.sort { $0.writtenAt > $1.writtenAt }
        hrxFlushEnvelope()
    }

    func hrxDropNote(_ id: UUID) {
        notes.removeAll { $0.id == id }
        hrxFlushEnvelope()
    }

    func hrxToggleFocus() {
        let key = HrxDayStamp.key(Date())
        if focusDoneDays.contains(key) {
            focusDoneDays.removeAll { $0 == key }
        } else {
            focusDoneDays.append(key)
        }
        hrxFlushEnvelope()
    }

    func hrxFocusDoneToday() -> Bool {
        focusDoneDays.contains(HrxDayStamp.key(Date()))
    }

    func hrxWeekRows() -> [(label: String, laps: Int, minutes: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let matching = sessions.filter { calendar.isDate($0.startedAt, inSameDayAs: day) }
            return (
                HrxDayStamp.shortWeekday(day),
                matching.reduce(0) { $0 + $1.lapTotal },
                matching.reduce(0) { $0 + $1.minuteSpan }
            )
        }
    }

    func hrxSetHomeRink(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        homeRink = trimmed.isEmpty ? "Home rink" : trimmed
        hrxFlushEnvelope()
    }

    func hrxSetLapGoal(_ value: Int) {
        lapGoal = min(80, max(1, value))
        hrxFlushEnvelope()
    }

    func hrxSetRoughEnd(_ end: String) {
        roughEnd = HrxRinkEnd(rawValue: end)?.rawValue ?? HrxRinkEnd.even.rawValue
        hrxFlushEnvelope()
    }

    func hrxReplayIntro() {
        onboardingCleared = false
        hrxFlushEnvelope()
    }

    func hrxMarkIntroCleared() {
        onboardingCleared = true
        hrxFlushEnvelope()
    }

    func hrxClearRink() {
        sessions = []
        repMarks = []
        routines = []
        notes = []
        focusDoneDays = []
        hrxFlushEnvelope()
    }

    private func hrxBootFromDisk() {
        guard let data = try? Data(contentsOf: fileURL),
              let envelope = try? JSONDecoder().decode(HrxDiskEnvelope.self, from: data) else { return }
        sessions = envelope.sessions.sorted { $0.startedAt > $1.startedAt }
        repMarks = envelope.repMarks
        routines = envelope.routines
        notes = envelope.notes.sorted { $0.writtenAt > $1.writtenAt }
        visitDays = envelope.visitDays
        focusDoneDays = envelope.focusDoneDays
        onboardingCleared = envelope.onboardingCleared
        homeRink = envelope.homeRink.isEmpty ? "Home rink" : envelope.homeRink
        lapGoal = min(80, max(1, envelope.lapGoal))
        roughEnd = HrxRinkEnd(rawValue: envelope.roughEnd)?.rawValue ?? HrxRinkEnd.even.rawValue
    }

    private func hrxFlushEnvelope() {
        let envelope = HrxDiskEnvelope(
            sessions: sessions,
            repMarks: repMarks,
            routines: routines,
            notes: notes,
            visitDays: visitDays,
            focusDoneDays: focusDoneDays,
            onboardingCleared: onboardingCleared,
            homeRink: homeRink,
            lapGoal: lapGoal,
            roughEnd: roughEnd
        )
        guard let data = try? JSONEncoder().encode(envelope) else { return }
        let soak = HrxKeelIntegral.hrxSoak(bytes: [UInt8](data.prefix(24)), count: sessions.count &+ notes.count)
        let survey = HrxRinkSurvey.hrxSurvey(seed: soak)
        let side = fileURL.deletingLastPathComponent().appendingPathComponent("keel-mark.txt")
        try? Data("\(survey)".utf8).write(to: side, options: .atomic)
        try? data.write(to: fileURL, options: .atomic)
    }
}
