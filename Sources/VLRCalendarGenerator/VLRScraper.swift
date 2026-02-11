//
//  VLRScraper.swift
//  VLRCalendarGenerator
//
//  Created by Chinh Ngo on 02.02.26.
//

import Foundation
import SwiftSoup

struct SimpleError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
}

struct Match: Codable {
    let startTimestamp: TimeInterval
    let homeTeam: String
    let awayTeam: String
    let event: String
    let series: String
}

extension Element {
    var formatedText: String {
        (try? self.text().trimmingCharacters(in: .whitespacesAndNewlines)) ?? ""
    }
}

struct VLRScraper {
    static func scrapeUpcomingMatches(
        pages: Int,
        logger: Logging? = nil
    ) async -> [Match] {
        let timeZone = await getTimeZone(logger: logger) ?? TimeZone(identifier: "America/Chicago")
        var matches = [Match]()
        for page in 1...pages {
            let urlString = "https://www.vlr.gg/matches?page=\(page)"
            guard let url = URL(string: urlString) else {
                logger?.error("Invalid URL")
                return matches
            }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let html = String(data: data, encoding: .utf8) else {
                    logger?.error("Failed to decode HTML")
                    return matches
                }
                let parsedMatches = try matchesFromHTML(html, timeZone: timeZone, logger: logger)
                matches.append(contentsOf: parsedMatches)
            } catch {
                logger?.error("Error fetching or parsing matches: \(error)")
            }
        }
        return matches
    }
    
    static func matchesFromHTML(
        _ html: String,
        timeZone: TimeZone? = nil,
        logger: Logging? = nil
    ) throws -> [Match] {
        let doc = try SwiftSoup.parse(html)
        guard let container = try doc.select("div.col.mod-1").first() else { return [] }
        var matches: [Match] = []
        var currentDate = ""
        let children = container.children()
        var i = 0
        while i < children.count {
            let element = children[i]
            let className = try element.className()
            if className.contains("wf-label") {
                currentDate = element.formatedText
                // Look ahead for the next wf-card
                if i + 1 < children.count {
                    let card = children[i + 1]
                    let cardClass = try card.className()
                    if cardClass.contains("wf-card") && !cardClass.contains("mod-header") {
                        let matchItems = try card.select("a.wf-module-item.match-item")
                        for matchElement in matchItems.array() {
                            do {
                                let match = try matchFromElement(matchElement, date: currentDate, timeZone: timeZone, logger: logger)
                                matches.append(match)
                            } catch {
                                logger?.debug("Error parse match: \(error)")
                                continue
                            }
                        }
                        i += 1 // Skip the card since we just processed it
                    }
                }
            }
            i += 1
        }
        return matches
    }
    
    static func getTimeZone(logger: Logging? = nil) async -> TimeZone? {
        let urlString = "https://www.vlr.gg"
        guard let url = URL(string: urlString) else {
            logger?.error("Invalid URL")
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let html = String(data: data, encoding: .utf8) else {
                logger?.error("Failed to decode HTML")
                return nil
            }
            return detectTimeZone(fromHTML: html, logger: logger)
        } catch {
            logger?.error("Failed to decode HTML")
            return nil
        }
    }
    
    /// Extracts a TimeZone from the provided VLR HTML by inspecting the preview time element.
    /// Returns the detected TimeZone, or nil if not found.
    static func detectTimeZone(fromHTML html: String, logger: Logging? = nil) -> TimeZone? {
        do {
            let doc = try SwiftSoup.parse(html)
            // Find the first preview time element that contains the displayed time with tz abbreviation
            if let preview = try doc.select("div.h-match-preview-time.moment-tz-convert").first() {
                let text = try preview.text().trimmingCharacters(in: .whitespacesAndNewlines)
                // Expect something like: "11:00 PM CET" or "9:30 AM PDT"
                let parts = text.split(separator: " ")
                if parts.count >= 3 {
                    let tzAbbr = String(parts.last!)
                    if let tz = timeZone(fromAbbreviation: tzAbbr) {
                        logger?.debug("detectTimeZone: Detected \(tz) for abbreviation \(tzAbbr)")
                        return tz
                    } else {
                        logger?.debug("detectTimeZone: Unrecognized abbreviation: \(tzAbbr)")
                    }
                } else {
                    logger?.debug("detectTimeZone: Unexpected preview text format: \(text)")
                }
            } else {
                logger?.debug("detectTimeZone: No preview element found")
            }
        } catch {
            logger?.debug("detectTimeZone: Failed to parse HTML: \(error)")
        }
        return nil
    }
    
    static func matchFromElement(
        _ matchElement: Element,
        date: String,
        timeZone: TimeZone? = nil,
        logger: Logging? = nil
    ) throws -> Match {
        var date = date
        if date.hasSuffix("Today") {
            let trimmed = date.dropLast("Today".count)
            date = trimmed.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let matchTime = try matchElement.select("div.match-item-time").first?.formatedText ?? ""
        let teams = try matchElement.select("div.match-item-vs-team-name")
        let homeTeam = teams.array().first?.formatedText ?? ""
        let awayTeam = teams.array().dropFirst().first?.formatedText ?? ""
        if homeTeam == "TBD" || awayTeam == "TBD" || matchTime == "TBD" {
            throw SimpleError(message: "TBD match")
        }
        let event = try matchElement.select("div.match-item-event.text-of").first?.ownText().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let series = try matchElement.select("div.match-item-event-series.text-of").first?.ownText().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let datetimeString = date.isEmpty ? matchTime : "\(date) \(matchTime)"
        logger?.debug("VLRScrapers: Parsing: \(datetimeString)")
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "EEE, MMMM d, yyyy h:mm a"
        let timestamp = formatter.date(from: datetimeString)?.timeIntervalSince1970 ?? 0
        if timestamp == 0 {
            logger?.debug("Failed to parse datetime: \(datetimeString)")
        }
        let match = Match(
            startTimestamp: timestamp,
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            event: event,
            series: series
        )
        let readableDate = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
        logger?.debug("\(timestamp) (\(readableDate)): \(match.homeTeam) vs \(match.awayTeam) — \(match.event), \(match.series)")
        return match
    }
}
