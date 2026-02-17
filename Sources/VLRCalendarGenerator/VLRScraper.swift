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
    let id: Int
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
    /// Fetches and parses upcoming matches from VLR across the specified number of pages.
    ///
    /// This method attempts to detect the site's current time zone via `getTimeZone(logger:)`
    /// and falls back to "America/Chicago" if detection fails. It then downloads and parses
    /// each matches page in order, accumulating the results.
    ///
    /// - Parameters:
    ///   - pages: The number of pages to fetch from the matches listing (starting at 1).
    ///   - logger: An optional logger used for diagnostics.
    /// - Returns: All `Match` values discovered across the requested pages.
    /// - Note: Network requests are performed sequentially. Matches with "TBD" times are skipped.
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
    
    /// Parses the HTML of a VLR matches listing page into `Match` values.
    ///
    /// The parser scans date labels and their following match cards, extracting
    /// the fields required to build each `Match`.
    ///
    /// - Parameters:
    ///   - html: The raw HTML string of a matches page.
    ///   - timeZone: The time zone used to interpret date/time strings when computing the start timestamp.
    ///   - logger: An optional logger used for diagnostics.
    /// - Returns: An array of parsed `Match` values.
    /// - Throws: An error if the HTML cannot be parsed into a document.
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
                                let match = try matchFromElement(
                                    matchElement,
                                    date: currentDate,
                                    timeZone: timeZone,
                                    logger: logger
                                )
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
    
    /// Retrieves the time zone used by VLR by loading the site home page.
    ///
    /// The returned time zone is determined by parsing the page via `detectTimeZone(fromHTML:logger:)`.
    ///
    /// - Parameter logger: An optional logger used for diagnostics.
    /// - Returns: The detected `TimeZone`, or `nil` if it could not be determined.
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
    
    /// Detects a `TimeZone` by inspecting VLR HTML for a preview time element.
    ///
    /// This function looks for a `div.h-match-preview-time.moment-tz-convert` element whose
    /// text ends with a time zone abbreviation (for example, "CET" or "PDT") and maps that
    /// abbreviation to a Foundation `TimeZone`.
    ///
    /// - Parameters:
    ///   - html: The raw HTML of a VLR page.
    ///   - logger: An optional logger used for diagnostics.
    /// - Returns: The detected `TimeZone`, or `nil` if no known abbreviation is found.
    static func detectTimeZone(fromHTML html: String, logger: Logging? = nil) -> TimeZone? {
        do {
            let doc = try SwiftSoup.parse(html)
            // Find the first preview time element that contains the displayed time with tz abbreviation
            if let preview = try doc.select("div.h-match-preview-time.moment-tz-convert").first() {
                let text = try preview.text().trimmingCharacters(in: .whitespacesAndNewlines)
                // Expect something like: "11:00 PM CET" or "9:30 AM PDT"
                let parts = text.split(separator: " ")
                if parts.count >= 3 {
                    let tzAbbr = String(parts.last ?? "N/A")
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
    
    /// Parses a single match item element into a `Match`.
    ///
    /// This reads the match identifier, teams, event, series, and time from the given element,
    /// combines them with the provided `date`, and converts the resulting date/time into a UNIX
    /// timestamp using the supplied `timeZone`.
    ///
    /// - Parameters:
    ///   - matchElement: The anchor element representing the match item.
    ///   - date: The date label string associated with the match card. If the string ends
    ///           with "Today", that suffix is removed before parsing.
    ///   - timeZone: The time zone used to interpret the match time string.
    ///   - logger: An optional logger used for diagnostics.
    /// - Returns: The parsed `Match`.
    /// - Throws: A `SimpleError` if the match identifier cannot be parsed or the match time is "TBD".
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
        let href = try matchElement.attr("href")
        let matchId = Int(href.split(separator: "/").first ?? "")
        guard let matchId = matchId else {
            throw SimpleError(message: "Failed to parse matchId: \(href)")
        }
        let matchTime = try matchElement.select("div.match-item-time").first?.formatedText ?? ""
        let teams = try matchElement.select("div.match-item-vs-team-name")
        let homeTeam = teams.array().first?.formatedText ?? ""
        let awayTeam = teams.array().dropFirst().first?.formatedText ?? ""
        if matchTime == "TBD" {
            throw SimpleError(message: "TBD match time")
        }
        let event = try matchElement
            .select("div.match-item-event.text-of")
            .first?
            .ownText()
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let series = try matchElement
            .select("div.match-item-event-series.text-of")
            .first?
            .ownText()
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
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
            id: matchId,
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
