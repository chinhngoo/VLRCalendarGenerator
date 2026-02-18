//
//  VLRCalendarGenerator.swift
//  VLRCalendarGenerator
//
//  Created by Chinh Ngo on 02.02.26.
//

import ArgumentParser
import Foundation

@main
struct VLRCalendarGenerator: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "vlr-calendar-generator",
        abstract: "Generate a VLR calendar from upcoming matches",
        version: "1.0.0"
    )

    @Flag(name: [.long, .short], help: "Enable verbose logging")
    var verbose: Bool = false

    @Option(name: .long, help: "Number of pages to scrape")
    var pages: Int = 5

    @Option(name: .long, help: "Output directory for generated files")
    var outputDir: String = "./Publish"

    /// Executes the command to scrape upcoming matches, generate calendar files, and build the static site.
    ///
    /// Orchestrates scraping VLR for upcoming matches, generating per-region, per-tournament, and per-team
    /// ICS files, and writing an index page into the output directory.
    ///
    /// - Throws: `SimpleError` if no matches are scraped, or any error encountered while creating directories or writing files.
    mutating func run() async throws {
        let logger: Logging = Logger(isVerbose: verbose)

        logger.debug("Verbose mode enabled")
        logger.debug("Arguments: \(CommandLine.arguments.dropFirst().joined(separator: " "))")

        logger.debug("Scraping upcoming matches for \(pages) pages…")
        let allMatches = await VLRScraper.scrapeUpcomingMatches(pages: pages, logger: logger)
        logger.debug("Retrieved \(allMatches.count) matches")
        if allMatches.isEmpty {
            throw SimpleError(message: "No match scraped.")
        }

        // Ensure output directory exists
        let outDirURL = URL(fileURLWithPath: outputDir)
        try FileManager.default.createDirectory(at: outDirURL, withIntermediateDirectories: true)
        let icsOutputURL = outDirURL.appendingPathComponent("ics")
        try FileManager.default.createDirectory(at: icsOutputURL, withIntermediateDirectories: true)
        
        logger.info("Generating ICS files…")
        let vctData = try await generateCalendars(from: allMatches, output: icsOutputURL, logger: logger)
        
        logger.info("Building static site…")
        let fullPage = HTMLBuilder.buildFullPage(data: vctData)
        let indexPageURL = outDirURL.appendingPathComponent("index.html")
        try fullPage.write(to: indexPageURL, atomically: true, encoding: .utf8)
    }
    
    /// Generates calendar files for VCT regions, tournaments, and teams and returns site metadata.
    ///
    /// Groups the provided matches by tournament and team, writes per-group ICS files, and aggregates
    /// VCT-branded matches into a single calendar.
    ///
    /// - Parameters:
    ///   - allMatches: The complete list of scraped matches.
    ///   - output: The directory where .ics files will be written.
    ///   - logger: The logger used for diagnostics.
    /// - Returns: A `VCTData` value describing the generated calendars for use when building the site.
    /// - Throws: Errors thrown while writing ICS files.
    private func generateCalendars(from allMatches: [Match], output: URL, logger: Logging) async throws -> VCTData {
        let regions: [Region] = [americas, china, emea, pacific]
        var regionFeeds: [RegionFeed] = []
        let tournamentDictionary: [String: [Match]] = Dictionary(grouping: allMatches, by: { $0.event })
        let teamDictionary: [String: [Match]] = allMatches.reduce(into: [:]) { dict, match in
            dict[match.homeTeam, default: []].append(match)
            dict[match.awayTeam, default: []].append(match)
        }

        for region in regions {
            var feed: RegionFeed = .init(name: region.name, tournaments: [], teams: [])
            for tournament in region.tournaments {
                let name = tournament.rawValue
                let matches = tournamentDictionary[name, default: []]
                let fileName = try writeICSFile(
                    matches: tournamentDictionary[name, default: []],
                    outDirURL: output,
                    calendarName: name,
                    name: sanitizedFileName(name),
                    logger: logger
                )
                feed.tournaments.append(.init(name: name, fileName: fileName))
            }
            for team in region.teams {
                let name = team.rawValue
                let fileName = try writeICSFile(
                    matches: teamDictionary[name, default: []],
                    outDirURL: output,
                    calendarName: name,
                    name: sanitizedFileName(name),
                    logger: logger
                )
                feed.teams.append(.init(name: name, fileName: fileName))
            }
            regionFeeds.append(feed)
        }

        let globalTournamentSources: [CalendarSource] = try globalTournaments.map { tournament in
            let name = tournament.rawValue
            let fileName = try writeICSFile(
                matches: tournamentDictionary[name, default: []],
                outDirURL: output,
                calendarName: name,
                name: sanitizedFileName(name),
                logger: logger
            )
            return CalendarSource(name: name, fileName: fileName)
        }

        let vctMatches = vctTournaments
            .flatMap { tournamentDictionary[$0.rawValue, default: []] }
            .sorted { $0.startTimestamp < $1.startTimestamp }
        
        let allMatchesName = "All VCT Matches"
        let vctFileName = try writeICSFile(
            matches: vctMatches,
            outDirURL: output,
            calendarName: allMatchesName,
            name: "All_VCT_Matches",
            logger: logger
        )

        return VCTData(
            allVCTMatches: CalendarSource(
                name: allMatchesName,
                fileName: vctFileName
            ),
            globalTournaments: globalTournamentSources,
            regions: regionFeeds
        )
    }
    
    /// Writes an .ics file for the given matches.
    ///
    /// Creates or overwrites a file named `name.ics` within `outDirURL` using `calendarName`
    /// as the calendar title.
    ///
    /// - Parameters:
    ///   - matches: The matches to include in the calendar (may be empty).
    ///   - outDirURL: The directory where the file should be written.
    ///   - calendarName: The human-readable calendar name embedded in the ICS content.
    ///   - name: The base file name (without extension) to use for the output file.
    ///   - logger: The logger used for diagnostics.
    /// - Returns: The last path component of the written file (e.g., "Team_X.ics").
    /// - Throws: An error if the content cannot be written to disk.
    private func writeICSFile(
        matches: [Match],
        outDirURL: URL,
        calendarName: String,
        name: String,
        logger: Logging
    ) throws -> String {
        if matches.isEmpty {
            logger.debug("No matches found for \(name)")
        }
        // Sometimes, there is no scheduled event for a specific team if they are eliminated
        // but the ics file should still updated so subsribers aren't interrupted
        let content = buildICS(from: matches, name: calendarName)
        let URL = outDirURL.appendingPathComponent(name + ".ics")
        try content.write(to: URL, atomically: true, encoding: .utf8)
        logger.info("Wrote \(name) events to \(URL.path)")
        return URL.lastPathComponent
    }
}
