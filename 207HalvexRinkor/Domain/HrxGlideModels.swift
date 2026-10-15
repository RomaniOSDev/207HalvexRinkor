import Foundation

enum HrxIceFace: String, CaseIterable, Identifiable {
    case fresh = "Fresh"
    case soft = "Soft"
    case chopped = "Chopped"

    var id: String { rawValue }
}

enum HrxRinkEnd: String, CaseIterable, Identifiable {
    case near = "Near end"
    case far = "Far end"
    case even = "Even"

    var id: String { rawValue }
}

enum HrxBladeSide {
    static let left = "onefoot-left"
    static let right = "onefoot-right"
}

struct HrxGlideSession: Identifiable, Codable, Equatable {
    var id: UUID
    var rinkLabel: String
    var startedAt: Date
    var lapTotal: Int
    var minuteSpan: Int
    var edgeFocus: String
    var balanceMark: Int
    var iceNote: String
    var iceFace: String

    init(id: UUID, rinkLabel: String, startedAt: Date, lapTotal: Int, minuteSpan: Int, edgeFocus: String, balanceMark: Int, iceNote: String, iceFace: String = HrxIceFace.fresh.rawValue) {
        self.id = id
        self.rinkLabel = rinkLabel
        self.startedAt = startedAt
        self.lapTotal = lapTotal
        self.minuteSpan = minuteSpan
        self.edgeFocus = edgeFocus
        self.balanceMark = balanceMark
        self.iceNote = iceNote
        self.iceFace = iceFace
    }

    init(from decoder: Decoder) throws {
        let box = try decoder.container(keyedBy: CodingKeys.self)
        id = try box.decode(UUID.self, forKey: .id)
        rinkLabel = try box.decode(String.self, forKey: .rinkLabel)
        startedAt = try box.decode(Date.self, forKey: .startedAt)
        lapTotal = try box.decode(Int.self, forKey: .lapTotal)
        minuteSpan = try box.decode(Int.self, forKey: .minuteSpan)
        edgeFocus = try box.decode(String.self, forKey: .edgeFocus)
        balanceMark = try box.decode(Int.self, forKey: .balanceMark)
        iceNote = try box.decode(String.self, forKey: .iceNote)
        iceFace = try box.decodeIfPresent(String.self, forKey: .iceFace) ?? HrxIceFace.fresh.rawValue
    }

    func encode(to encoder: Encoder) throws {
        var box = encoder.container(keyedBy: CodingKeys.self)
        try box.encode(id, forKey: .id)
        try box.encode(rinkLabel, forKey: .rinkLabel)
        try box.encode(startedAt, forKey: .startedAt)
        try box.encode(lapTotal, forKey: .lapTotal)
        try box.encode(minuteSpan, forKey: .minuteSpan)
        try box.encode(edgeFocus, forKey: .edgeFocus)
        try box.encode(balanceMark, forKey: .balanceMark)
        try box.encode(iceNote, forKey: .iceNote)
        try box.encode(iceFace, forKey: .iceFace)
    }

    private enum CodingKeys: String, CodingKey {
        case id, rinkLabel, startedAt, lapTotal, minuteSpan, edgeFocus, balanceMark, iceNote, iceFace
    }
}

struct HrxSkillLeaf: Identifiable {
    var id: String
    var title: String
    var detail: String
    var cue: String
}

struct HrxRepMark: Identifiable, Codable, Equatable {
    var id: String
    var dayKey: String
    var drillId: String
    var reps: Int
}

struct HrxRoutineStrand: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var drillIds: [String]
    var note: String
}

struct HrxIceJot: Identifiable, Codable, Equatable {
    var id: UUID
    var rinkLabel: String
    var writtenAt: Date
    var body: String
    var feel: Int
}

enum HrxEdgeCatalog {
    static let focuses = ["Forward edges", "Backward edges", "Crossovers", "Snowplow stops", "One-foot glide", "Two-foot turns"]

    static let skills: [HrxSkillLeaf] = [
        HrxSkillLeaf(id: "forward", title: "Forward edges", detail: "Glide on an outside edge, then an inside edge, one length each.", cue: "Ankle quiet, knee over the toe."),
        HrxSkillLeaf(id: "backward", title: "Backward edges", detail: "Short backward glides. Look over the shoulder you are turning toward.", cue: "Hips stay square until the edge is set."),
        HrxSkillLeaf(id: "cross", title: "Crossovers", detail: "Four crossovers each way around a circle.", cue: "The free foot crosses close, not wide."),
        HrxSkillLeaf(id: "stop", title: "Snowplow stops", detail: "Build speed, then stop with both blades angled in.", cue: "Bend the knees before the blades bite."),
        HrxSkillLeaf(id: "onefoot", title: "One-foot glide", detail: "Hold one foot for a slow count of eight, then switch.", cue: "Arms stay low and wide."),
        HrxSkillLeaf(id: "turns", title: "Two-foot turns", detail: "Turn forward to backward and back, on a gentle curve.", cue: "Turn the shoulders first.")
    ]

    static func packet(for date: Date) -> HrxSkillLeaf {
        let index = Calendar.current.component(.weekday, from: date) % skills.count
        return skills[index]
    }

    static func skill(_ id: String) -> HrxSkillLeaf? {
        skills.first { $0.id == id }
    }
}

enum HrxDayStamp {
    static func key(_ date: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year ?? 0).\(parts.month ?? 0).\(parts.day ?? 0)"
    }

    static func moment(from token: String) -> Date? {
        let bits = token.split(separator: ".").compactMap { Int($0) }
        guard bits.count == 3 else { return nil }
        var parts = DateComponents()
        parts.calendar = Calendar(identifier: .gregorian)
        parts.year = bits[0]
        parts.month = bits[1]
        parts.day = bits[2]
        return parts.date
    }

    static func shortWeekday(_ date: Date) -> String {
        let symbols = Calendar(identifier: .gregorian).shortWeekdaySymbols
        let index = Calendar(identifier: .gregorian).component(.weekday, from: date) - 1
        guard symbols.indices.contains(index) else { return "" }
        return symbols[index]
    }

    static func medium(_ date: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let parts = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
        return "\(parts.month ?? 0)/\(parts.day ?? 0) \(parts.hour ?? 0):\(String(format: "%02d", parts.minute ?? 0))"
    }
}
