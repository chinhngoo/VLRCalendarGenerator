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
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
    formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
    return formatter.string(from: date)
}

// Create a VEVENT block from a Match.
func vevent(for match: Match, now: Date = Date()) -> String {
    let start = Date(timeIntervalSince1970: TimeInterval(match.startTimestamp))
    let end = Date(timeIntervalSince1970: TimeInterval(match.startTimestamp + 2 * 60 * 60)) // +2 hours

    let dtstamp = icsDateString(now)
    let dtstart = icsDateString(start)
    let dtend = icsDateString(end)

    let summary = "\(match.homeTeam) vs \(match.awayTeam) - \(match.event)"

    return """
    BEGIN:VEVENT
    UID:\(match.id)
    DTSTAMP:\(dtstamp)
    DTSTART:\(dtstart)
    DTEND:\(dtend)
    SUMMARY:\(icsEscape(summary))
    DESCRIPTION:\(icsEscape(match.series))
    END:VEVENT
    """
}

// Build a full VCALENDAR from matches.
func buildICS(from matches: [Match], name: String) -> String {
    var lines: [String] = []
    lines.append("BEGIN:VCALENDAR")
    lines.append("VERSION:2.0")
    lines.append("PRODID:-//VLRCalendarGenerator//EN")
    lines.append("X-WR-CALNAME:\(name)")
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
