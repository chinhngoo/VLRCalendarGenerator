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
        let ICSOutputURL = outDirURL.appendingPathComponent("ICS")
        try FileManager.default.createDirectory(at: ICSOutputURL, withIntermediateDirectories: true)

        // ICS for all VCT tournaments
        let tournamentSet = Set(VCTTournaments.map { $0.rawValue })
        let tournamentMatches = allMatches.filter { tournamentSet.contains($0.event) }
        try writeICSFile(
            matches: tournamentMatches,
            outDirURL: ICSOutputURL,
            name: "VCT",
            logger: logger
        )

        // Per tournament ICS
        for tournament in VCTTournaments {
            let name = tournament.rawValue
            let filtered = allMatches.filter { $0.event == name }
            let fileName = sanitizedFileName(name)
            try writeICSFile(
                matches: filtered,
                outDirURL: ICSOutputURL,
                name: fileName,
                logger: logger
            )
        }

        // Per team ICS
        let allTeams = AMERICATeams + ChinaTeams + EMEATeams + PACIFICTeams
        for team in allTeams {
            let name = team.rawValue
            let filtered = allMatches.filter { $0.homeTeam == name || $0.awayTeam == name }
            try writeICSFile(
                matches: filtered,
                outDirURL: ICSOutputURL,
                name: sanitizedFileName(name),
                logger: logger
            )
        }
        
        // Generate a simple index.html with links to all generated ICS files
        let indexURL = outDirURL.appendingPathComponent("generatedhtml.html")
        try html.write(to: indexURL, atomically: true, encoding: .utf8)
        logger.info("Wrote site index to \(indexURL.path)")
    }
    
    private func writeICSFile(
        matches: [Match],
        outDirURL: URL,
        name: String,
        logger: Logging
    ) throws {
        if matches.isEmpty {
            logger.debug("No matches found for \(name)")
        }
        // Sometimes, there is no scheduled event for a specific team if they are eliminated
        // but the ics file should still updated
        let content = buildICS(from: matches)
        let URL = outDirURL.appendingPathComponent(name + ".ics")
        try content.write(to: URL, atomically: true, encoding: .utf8)
        logger.info("Wrote \(name) events to \(URL.path)")
    }
}
