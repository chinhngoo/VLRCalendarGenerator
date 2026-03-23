//
//  Tournament.swift
//  VLRCalendarGenerator
//
//  Created by Chinh Ngo on 02.02.26.
//

// Ongoing and upcoming tournaments to be exact
enum Tournament: String {
    case vct2026AmericasStage1 = "VCT 2026: Americas Stage 1"
    case vct2026EmeaStage1 = "VCT 2026: EMEA Stage 1"
    case vct2026PacificStage1 = "VCT 2026: Pacific Stage 1"
    case vct2026ChinaStage1 = "VCT 2026: China Stage 1"
    // swiftlint:disable:next inclusive_language
    case vct2026MastersLondon2026 = "Valorant Masters London 2026"
    case vct2026Champions2026  = "Valorant Champions 2026"
}

let vctTournaments: [Tournament] = [
    .vct2026AmericasStage1,
    .vct2026EmeaStage1,
    .vct2026PacificStage1,
    .vct2026ChinaStage1,
    .vct2026MastersLondon2026,
    .vct2026Champions2026
]

let globalTournaments: [Tournament] = [
    .vct2026MastersLondon2026,
    .vct2026Champions2026
]

let emeaTournaments: [Tournament] = [
    .vct2026EmeaStage1
]

let chinaTournaments: [Tournament] = [
    .vct2026ChinaStage1
]

let pacificTournaments: [Tournament] = [
    .vct2026PacificStage1
]

let americasTournaments: [Tournament] = [
    .vct2026AmericasStage1
]
