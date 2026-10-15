import Foundation

struct HrxDayPulse: Identifiable, Equatable {
    var id: String
    var label: String
    var laps: Int
    var minutes: Int
    var fresh: Int
    var soft: Int
    var chopped: Int
}

struct HrxHourMirror: Equatable {
    var nowLaps: Int
    var thenLaps: Int
    var line: String
}

struct HrxEdgeSlice: Identifiable, Equatable {
    var id: String
    var title: String
    var laps: Int
}

enum HrxGlideMath {
    static func pulses(sessions: [HrxGlideSession], days: Int = 7, now: Date = Date()) -> [HrxDayPulse] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let span = max(1, days)
        return (0..<span).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let matching = sessions.filter { calendar.isDate($0.startedAt, inSameDayAs: day) }
            return HrxDayPulse(
                id: HrxDayStamp.key(day),
                label: HrxDayStamp.shortWeekday(day),
                laps: matching.reduce(0) { $0 + $1.lapTotal },
                minutes: matching.reduce(0) { $0 + $1.minuteSpan },
                fresh: matching.filter { ($0.iceFace.isEmpty ? HrxIceFace.fresh.rawValue : $0.iceFace) == HrxIceFace.fresh.rawValue }.count,
                soft: matching.filter { $0.iceFace == HrxIceFace.soft.rawValue }.count,
                chopped: matching.filter { $0.iceFace == HrxIceFace.chopped.rawValue }.count
            )
        }
    }

    static func edgeSlices(sessions: [HrxGlideSession]) -> [HrxEdgeSlice] {
        HrxEdgeCatalog.focuses.map { title in
            let laps = sessions.filter { $0.edgeFocus == title }.reduce(0) { $0 + $1.lapTotal }
            return HrxEdgeSlice(id: title, title: title, laps: laps)
        }
    }

    static func paceClock(sessions: [HrxGlideSession]) -> String {
        let laps = sessions.reduce(0) { $0 + max(0, $1.lapTotal) }
        let minutes = sessions.reduce(0) { $0 + max(0, $1.minuteSpan) }
        guard laps > 0 else { return "—" }
        let seconds = (minutes * 60) / laps
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    static func glideIndex(sessions: [HrxGlideSession], now: Date = Date()) -> Int {
        guard !sessions.isEmpty else { return 0 }
        let balance = Double(sessions.map(\.balanceMark).reduce(0, +)) / Double(sessions.count)
        let balanceScore = (balance / 5.0) * 70.0
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        var hits = 0
        for offset in 0..<7 {
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            if sessions.contains(where: { calendar.isDate($0.startedAt, inSameDayAs: day) && $0.lapTotal > 0 }) {
                hits += 1
            }
        }
        let consistency = Double(hits) / 7.0 * 30.0
        return min(100, Int((balanceScore + consistency).rounded()))
    }

    static func biasLine(sessions: [HrxGlideSession]) -> String {
        let ranked = edgeSlices(sessions: sessions).sorted { $0.laps > $1.laps }
        guard let top = ranked.first, top.laps > 0 else {
            return "The trace stays flat until a skate is saved."
        }
        let quiet = ranked.last?.title ?? top.title
        return "\(top.title) carries \(top.laps) laps. \(quiet) is the quiet edge."
    }

    static func hourMirror(sessions: [HrxGlideSession], now: Date = Date()) -> HrxHourMirror {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        func laps(on day: Date) -> Int {
            sessions.filter {
                calendar.isDate($0.startedAt, inSameDayAs: day) && calendar.component(.hour, from: $0.startedAt) == hour
            }.reduce(0) { $0 + $1.lapTotal }
        }
        let nowLaps = laps(on: now)
        let thenLaps = laps(on: weekAgo)
        let line: String
        if nowLaps == 0 && thenLaps == 0 {
            line = "This hour is quiet, this week and last."
        } else if thenLaps == 0 {
            line = "\(nowLaps) laps in this hour. Last week this hour was empty."
        } else if nowLaps == thenLaps {
            line = "\(nowLaps) laps in this hour, matching last week."
        } else if nowLaps > thenLaps {
            line = "\(nowLaps) laps in this hour, \(nowLaps - thenLaps) ahead of last week."
        } else {
            line = "\(nowLaps) laps in this hour, \(thenLaps - nowLaps) behind last week."
        }
        return HrxHourMirror(nowLaps: nowLaps, thenLaps: thenLaps, line: line)
    }
}

enum HrxPaceBook {
    static func secondsPerLap(_ session: HrxGlideSession) -> Int? {
        guard session.lapTotal > 0 else { return nil }
        return (max(0, session.minuteSpan) * 60) / session.lapTotal
    }

    static func bestSeconds(edge: String, sessions: [HrxGlideSession], excluding id: UUID? = nil) -> Int? {
        sessions
            .filter { $0.edgeFocus == edge && $0.id != id }
            .compactMap(secondsPerLap)
            .min()
    }

    static func clock(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    static func beatNote(session: HrxGlideSession, among sessions: [HrxGlideSession]) -> String? {
        guard let pace = secondsPerLap(session) else { return nil }
        guard let prior = bestSeconds(edge: session.edgeFocus, sessions: sessions, excluding: session.id) else { return nil }
        guard pace < prior else { return nil }
        return "New pace on \(session.edgeFocus): \(clock(pace)). The old mark was \(clock(prior))."
    }

    static func latestHoldsMark(edge: String, sessions: [HrxGlideSession]) -> Bool {
        guard let best = bestSeconds(edge: edge, sessions: sessions) else { return false }
        guard let latest = sessions.filter({ $0.edgeFocus == edge }).max(by: { $0.startedAt < $1.startedAt }) else { return false }
        return secondsPerLap(latest) == best
    }
}

enum HrxOvalDraft {
    static func faceClock(laps: Int, goal: Int) -> String {
        guard goal > 0 else { return "0" }
        let share = min(1, Double(laps) / Double(goal))
        return String(format: "%.0f", share * 100)
    }

    static func ribbon(laps: Int, goal: Int) -> CGFloat {
        guard goal > 0 else { return 0 }
        return min(1, CGFloat(laps) / CGFloat(goal))
    }
}
