//
//  Team.swift
//  VLRCalendarGenerator
//
//  Created by Chinh Ngo on 02.02.26.
//

enum Team: String, Codable, CaseIterable {
    // EMEA Partners
    case BBLEsport = "BBL Esport"
    case FNATIC = "FNATIC"
    case FUTEsports = "FUT Esports"
    case GentleMates = "Gentle Mates"
    case GIANTX = "GIANTX"
    case KarmineCorp = "Karmine Corp"
    case NatusVincere = "Natus Vincere"
    case TeamHeretics = "Team Heretics"
    case TeamLiquid = "Team Liquid"
    case TeamVitality = "Team Vitality"
    case ULFEsports = "ULF Esports"
    case PCIFICEsports = "PCIFIC Esports"
    // AMERICA Partners
    case HunredThieves = "100 Thieves"
    case Cloud9 = "Cloud9"
    case EvilGeniuses = "Evil Geniuses"
    case FURIA = "FURIA"
    case KRUEsports = "KRÜ Esports"
    case LEVIATAN = "LEVIATÁN"
    case LOUD = "LOUD"
    case MIBR = "MIBR"
    case NRG = "NRG"
    case Sentinels = "Sentinels"
    case G2Esports = "G2 Esports"
    case ENVY = "ENVY"
    // PACIFIC Partners
    case DetonatioNFocusMe = "DetonatioN FocusMe"
    case DRX = "DRX"
    case FullSense = "FULL SENSE"
    case GenG = "Gen.G"
    case GlobalEsports = "Global Esports"
    case PaperRex = "Paper Rex"
    case RexRegumQeon = "Rex Regum Qeon"
    case T1 = "T1"
    case TeamSecret = "Team Secret"
    case ZetaDivision = "ZETA DIVISION"
    case VARREL = "VARREL"
    case NongshimRedForce = "Nongshim RedForce"
    // CHINA Partners
    case AllGamers = "All Gamers"
    case BilibililiGaming = "Bilibili Gaming"
    case EdwardGaming = "EDward Gaming"
    case FunPlusPhoenix = "FunPlus Phoenix"
    case JDGEsports = "JDG Esports"
    case NovaEsports = "Nova Esports"
    case TitaEsportsClub = "Titan Esports Club"
    case TraceEsports = "Trace Esports"
    case TYLOO = "TYLOO"
    case WolvesEsports = "Wolves Esports"
    case XiLaiGaming = "Xi Lai Gaming"
    case DragonRangerGaming = "Dragon Ranger Gaming"
}

let emeaTeams: [Team] = [
    .BBLEsport,
    .FNATIC,
    .FUTEsports,
    .GentleMates,
    .GIANTX,
    .KarmineCorp,
    .NatusVincere,
    .TeamHeretics,
    .TeamLiquid,
    .TeamVitality,
    .ULFEsports,
    .PCIFICEsports
]

let americasTeams: [Team] = [
    .HunredThieves,
    .Cloud9,
    .EvilGeniuses,
    .FURIA,
    .KRUEsports,
    .LEVIATAN,
    .LOUD,
    .MIBR,
    .NRG,
    .Sentinels,
    .G2Esports,
    .ENVY
]

let pacificTeams: [Team] = [
    .DetonatioNFocusMe,
    .DRX,
    .FullSense,
    .GenG,
    .GlobalEsports,
    .PaperRex,
    .RexRegumQeon,
    .T1,
    .TeamSecret,
    .ZetaDivision,
    .VARREL,
    .NongshimRedForce
]

let chinaTeams: [Team] = [
    .AllGamers,
    .BilibililiGaming,
    .EdwardGaming,
    .FunPlusPhoenix,
    .JDGEsports,
    .NovaEsports,
    .TitaEsportsClub,
    .TraceEsports,
    .TYLOO,
    .WolvesEsports,
    .XiLaiGaming,
    .DragonRangerGaming
]
