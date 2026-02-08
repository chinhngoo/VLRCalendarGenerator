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
