//
//  ICSBuilder.swift
//  VLRCalendarGenerator
//
//  Created by Assistant on 05.02.26.
//

import Foundation

// Escape text per RFC 5545 for commas, semicolons, backslashes, and newlines.
func icsEscape(_ text: String) -> String {
    text
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: ";", with: "\\;")
        .replacingOccurrences(of: ",", with: "\\,")
        .replacingOccurrences(of: "\n", with: "\\n")
}

// Format dates as UTC Zulu timestamps: 20260203T170000Z
func icsDateString(_ date: Date) -> String {
    let f = DateFormatter()
    f.calendar = Calendar(identifier: .gregorian)
    f.locale = Locale(identifier: "en_US_POSIX")
    f.timeZone = TimeZone(secondsFromGMT: 0) // UTC
    f.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
    return f.string(from: date)
}

// Build a stable UID by combining fields and removing spaces.
func icsUID(event: String, series: String, homeTeam: String, awayTeam: String) -> String {
    let combined = "\(event)\(series)\(homeTeam)\(awayTeam)"
    let noSpaces = combined.replacingOccurrences(of: " ", with: "")
    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_.@"))
    let safeScalars = noSpaces.unicodeScalars.filter { allowed.contains($0) }
    return String(String.UnicodeScalarView(safeScalars))
}

// Create a VEVENT block from a Match.
func vevent(for match: Match, now: Date = Date()) -> String {
    let start = Date(timeIntervalSince1970: TimeInterval(match.startTimestamp))
    let end = Date(timeIntervalSince1970: TimeInterval(match.startTimestamp + 2 * 60 * 60)) // +2 hours

    let uid = icsUID(event: match.event, series: match.series, homeTeam: match.homeTeam, awayTeam: match.awayTeam)

    let dtstamp = icsDateString(now)
    let dtstart = icsDateString(start)
    let dtend = icsDateString(end)

    let summary = "\(match.event) — \(match.homeTeam) vs \(match.awayTeam)"

    return """
    BEGIN:VEVENT
    UID:\(uid)
    DTSTAMP:\(dtstamp)
    DTSTART:\(dtstart)
    DTEND:\(dtend)
    SUMMARY:\(icsEscape(summary))
    DESCRIPTION:\(icsEscape(match.series))
    END:VEVENT
    """
}

// Build a full VCALENDAR from matches.
func buildICS(from matches: [Match]) -> String {
    var lines: [String] = []
    lines.append("BEGIN:VCALENDAR")
    lines.append("VERSION:2.0")
    lines.append("PRODID:-//VLRCalendarGenerator//EN")
    lines.append("CALSCALE:GREGORIAN")
    lines.append("METHOD:PUBLISH")

    let now = Date()
    for match in matches {
        let ev = vevent(for: match, now: now)
        lines.append(ev)
    }

    lines.append("END:VCALENDAR")
    return lines.joined(separator: "\n")
}
