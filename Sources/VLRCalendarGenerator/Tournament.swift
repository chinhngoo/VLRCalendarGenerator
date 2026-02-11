//
//  Tournament.swift
//  VLRCalendarGenerator
//
//  Created by Chinh Ngo on 02.02.26.
//

enum Tournament: String {
    case VCT2026EMEAKickoff = "VCT 2026: EMEA Kickoff"
    case VCT2026ChinaKickoff = "VCT 2026: China Kickoff"
    case VCT2026PacificKickoff = "VCT 2026: Pacific Kickoff"
    case VCT2026AmericasKickoff = "VCT 2026: Americas Kickoff"
}

let vctTournaments: [Tournament] = [
    Tournament.VCT2026EMEAKickoff,
    Tournament.VCT2026ChinaKickoff,
    Tournament.VCT2026PacificKickoff,
    Tournament.VCT2026AmericasKickoff
]

let emeaTournaments: [Tournament] = [
    Tournament.VCT2026EMEAKickoff
]

let chinaTournaments: [Tournament] = [
    Tournament.VCT2026ChinaKickoff
]

let pacificTournaments: [Tournament] = [
    Tournament.VCT2026PacificKickoff
]

let americasTournaments: [Tournament] = [
    Tournament.VCT2026AmericasKickoff
]
