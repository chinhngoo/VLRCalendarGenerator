//
//  Team.swift
//  VLRCalendarGenerator
//
//  Created by Chinh Ngo on 02.02.26.
//

enum Team: String, Codable, CaseIterable {
    // EMEA Partners
    case bblEsport = "BBL Esport"
    case fnatic = "FNATIC"
    case futEsports = "FUT Esports"
    case gentleMates = "Gentle Mates"
    case giantx = "GIANTX"
    case karmineCorp = "Karmine Corp"
    case natusVincere = "Natus Vincere"
    case teamHeretics = "Team Heretics"
    case teamLiquid = "Team Liquid"
    case teamVitality = "Team Vitality"
    case ulfEsports = "ULF Esports"
    case pcificEsports = "PCIFIC Esports"
    // AMERICA Partners
    case hunredThieves = "100 Thieves"
    case cloud9 = "Cloud9"
    case evilGeniuses = "Evil Geniuses"
    case furia = "FURIA"
    case kruEsports = "KRÜ Esports"
    case leviatan = "LEVIATÁN"
    case loud = "LOUD"
    case mibr = "MIBR"
    case nrg = "NRG"
    case sentinels = "Sentinels"
    case g2Esports = "G2 Esports"
    case envy = "ENVY"
    // PACIFIC Partners
    case detonationFocusMe = "DetonatioN FocusMe"
    case drx = "DRX"
    case fullSense = "FULL SENSE"
    case genG = "Gen.G"
    case globalEsports = "Global Esports"
    case paperRex = "Paper Rex"
    case rexRegumQeon = "Rex Regum Qeon"
    case t1 = "T1"
    case teamSecret = "Team Secret"
    case zetaDivision = "ZETA DIVISION"
    case varrel = "VARREL"
    case nongshimRedForce = "Nongshim RedForce"
    // CHINA Partners
    case allGamers = "All Gamers"
    case bilibililiGaming = "Bilibili Gaming"
    case edwardGaming = "EDward Gaming"
    case funPlusPhoenix = "FunPlus Phoenix"
    case jdgEsports = "JDG Esports"
    case novaEsports = "Nova Esports"
    case titanEsportsClub = "Titan Esports Club"
    case traceEsports = "Trace Esports"
    case tyloo = "TYLOO"
    case wolvesEsports = "Wolves Esports"
    case xiLaiGaming = "Xi Lai Gaming"
    case dragonRangerGaming = "Dragon Ranger Gaming"
}

let emeaTeams: [Team] = [
    .bblEsport,
    .fnatic,
    .futEsports,
    .gentleMates,
    .giantx,
    .karmineCorp,
    .natusVincere,
    .teamHeretics,
    .teamLiquid,
    .teamVitality,
    .ulfEsports,
    .pcificEsports
]

let americasTeams: [Team] = [
    .hunredThieves,
    .cloud9,
    .evilGeniuses,
    .furia,
    .kruEsports,
    .leviatan,
    .loud,
    .mibr,
    .nrg,
    .sentinels,
    .g2Esports,
    .envy
]

let pacificTeams: [Team] = [
    .detonationFocusMe,
    .drx,
    .fullSense,
    .genG,
    .globalEsports,
    .paperRex,
    .rexRegumQeon,
    .t1,
    .teamSecret,
    .zetaDivision,
    .varrel,
    .nongshimRedForce
]

let chinaTeams: [Team] = [
    .allGamers,
    .bilibililiGaming,
    .edwardGaming,
    .funPlusPhoenix,
    .jdgEsports,
    .novaEsports,
    .titanEsportsClub,
    .traceEsports,
    .tyloo,
    .wolvesEsports,
    .xiLaiGaming,
    .dragonRangerGaming
]
