//
//  Region.swift
//  VLRCalendarGenerator
//
//  Created by Chinh Ngo on 11.02.26.
//

struct Region {
    let name: String
    let tournaments: [Tournament]
    let teams: [Team]
}

let emea = Region(name: "EMEA", tournaments: emeaTournaments, teams: emeaTeams)
let americas = Region(name: "Americas", tournaments: americasTournaments, teams: americasTeams)
let china = Region(name: "China", tournaments: chinaTournaments, teams: chinaTeams)
let pacific = Region(name: "Pacific", tournaments: pacificTournaments, teams: pacificTeams)
