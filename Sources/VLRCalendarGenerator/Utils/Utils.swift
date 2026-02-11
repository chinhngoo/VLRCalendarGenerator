//
//  Utils.swift
//  VLRCalendarGenerator
//
//  Created by Chinh Ngo on 08.02.26.
//
import Foundation

func sanitizedFileName(_ raw: String) -> String {
    // Normalize to NFD (decomposed), strip diacritics, then to NFC
    let decomposed = raw.decomposedStringWithCanonicalMapping
    let withoutDiacritics = decomposed.unicodeScalars.filter {
        !CharacterSet.nonBaseCharacters.contains($0)
    }
    let asciiLike = String(String.UnicodeScalarView(withoutDiacritics))

    // Replace invalid filename characters and spaces
    let invalid = CharacterSet(charactersIn: ":/\\?%*|\"<>")
    let replaced = asciiLike.components(separatedBy: invalid).joined(separator: "_")
    let underscored = replaced.replacingOccurrences(of: " ", with: "_")

    // Optional: lowercasing, collapsing multiple underscores, etc.
    return underscored
}

func timeZone(fromAbbreviation abbreviation: String) -> TimeZone? {
    let mapping: [String: String] = [
          "CET": "Europe/Paris",
          "CEST": "Europe/Paris",
          "PST": "America/Los_Angeles",
          "PDT": "America/Los_Angeles",
          "EST": "America/New_York",
          "EDT": "America/New_York",
          "GMT": "GMT",
          "UTC": "UTC",
          "BST": "Europe/London"
      ]
    if let id = mapping[abbreviation] {
        return TimeZone(identifier: id)
    }
    return nil
}
