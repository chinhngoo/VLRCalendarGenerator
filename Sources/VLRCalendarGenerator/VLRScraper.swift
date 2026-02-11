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
    let startTimestamp: Int
    let homeTeam: String
    let awayTeam: String
    let event: String
    let series: String

    static func parseDateStringToTimestamp(
        _ dateString: String
    ) -> Int {
        let formatter = dateFormatter
        if let date = formatter.date(from: dateString) {
            return Int(date.timeIntervalSince1970)
        } else {
            print("Failed to parse datetime: \(dateString)")
            return 0
        }
    }

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "EEE, MMMM d, yyyy h:mm a"
        return formatter
    }
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
                let parsedMatches = try matchesFromHTML(html, logger: logger)
                matches.append(contentsOf: parsedMatches)
            } catch {
                logger?.error("Error fetching or parsing matches: \(error)")
            }
        }
        return matches
    }

    static func matchesFromHTML(
        _ html: String,
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
                                let match = try matchFromElement(matchElement, date: currentDate, logger: logger)
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

    static func matchFromElement(
        _ matchElement: Element,
        date: String,
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
        let timestamp = Match.parseDateStringToTimestamp(datetimeString)
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
        let readableDate = Match.dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
        logger?.debug("\(timestamp) (\(readableDate)): \(match.homeTeam) vs \(match.awayTeam) — \(match.event), \(match.series)")
        return match
    }
}
