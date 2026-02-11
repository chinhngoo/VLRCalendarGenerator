//
//  VLRCalendarGenerator.swift
//  VLRCalendarGenerator
//
//  Created by Chinh Ngo on 02.02.26.
//

import Foundation
import ArgumentParser

@main
struct VLRCalendarGenerator: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate a VLR calendar from upcoming matches"
    )

    @Flag(name: [.long, .short], help: "Enable verbose logging")
    var verbose: Bool = false

    @Option(name: .long, help: "Number of pages to scrape")
    var pages: Int = 5

    @Option(name: .long, help: "Output directory for generated files")
    var outputDir: String = "./Publish"

    mutating func run() async throws {
        let logger: Logging = Logger(isVerbose: verbose)

        logger.debug("Verbose mode enabled")
        logger.debug("Arguments: \(CommandLine.arguments.dropFirst().joined(separator: " "))")

        logger.debug("Scraping upcoming matches for \(pages) pages…")
        let allMatches = await VLRScraper.scrapeUpcomingMatches(pages: pages, logger: logger)
        logger.debug("Retrieved \(allMatches.count) matches")

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
    
    private func generateCalendars(from allMatches: [Match], output: URL, logger: Logging) async throws -> VCTData {
        var vctMatches: [Match] = []
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
                    name: sanitizedFileName(name),
                    logger: logger
                )
                feed.tournaments.append(.init(name: name, fileName: fileName))
                if vctTournaments.contains(tournament) {
                    vctMatches += matches
                }
            }
            for team in region.teams {
                let name = team.rawValue
                let fileName = try writeICSFile(
                    matches: teamDictionary[name, default: []],
                    outDirURL: output,
                    name: sanitizedFileName(name),
                    logger: logger
                )
                feed.teams.append(.init(name: name, fileName: fileName))
            }
            regionFeeds.append(feed)
        }
        let vctFileName = try writeICSFile(
            matches: vctMatches,
            outDirURL: output,
            name: "All_VCT_Matches",
            logger: logger
        )

        return VCTData(
            allVCTMatches: CalendarSource(
                name: "All VCT Matches",
                fileName: vctFileName
            ),
            regions: regionFeeds
        )
    }
    
    private func writeICSFile(
        matches: [Match],
        outDirURL: URL,
        name: String,
        logger: Logging
    ) throws -> String {
        if matches.isEmpty {
            logger.debug("No matches found for \(name)")
        }
        // Sometimes, there is no scheduled event for a specific team if they are eliminated
        // but the ics file should still updated so subsribers aren't interrupted
        let content = buildICS(from: matches)
        let URL = outDirURL.appendingPathComponent(name + ".ics")
        try content.write(to: URL, atomically: true, encoding: .utf8)
        logger.info("Wrote \(name) events to \(URL.path)")
        return URL.lastPathComponent
    }
}
