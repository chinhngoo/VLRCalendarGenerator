//
//  Tournament.swift
//  VLRCalendarGenerator
//
//  Created by Chinh Ngo on 02.02.26.
//

// Ongoing and upcoming tournaments to be exact
enum Tournament: String {
    case vct2026AmericasStage2 = "VCT 2026: Americas Stage 2"
    case vct2026EmeaStage2 = "VCT 2026: EMEA Stage 2"
    case vct2026PacificStage2 = "VCT 2026: Pacific Stage 2"
    case vct2026ChinaStage2 = "VCT 2026: China Stage 2"
    case vct2026Champions2026  = "Valorant Champions 2026"
}

let vctTournaments: [Tournament] = [
    .vct2026AmericasStage2,
    .vct2026EmeaStage2,
    .vct2026PacificStage2,
    .vct2026ChinaStage2,
    .vct2026Champions2026
]

let globalTournaments: [Tournament] = [
    .vct2026Champions2026
]

let emeaTournaments: [Tournament] = [
    .vct2026EmeaStage2
]

let chinaTournaments: [Tournament] = [
    .vct2026ChinaStage2
]

let pacificTournaments: [Tournament] = [
    .vct2026PacificStage2
]

let americasTournaments: [Tournament] = [
    .vct2026AmericasStage2
]
