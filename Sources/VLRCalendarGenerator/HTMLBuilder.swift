//
//  HTMLBuilder.swift
//  VLRCalendarGenerator
//
//  Created by Chinh Ngo on 09.02.26.
//

struct CalendarSource {
    let name: String
    let fileName: String
}

struct RegionFeed {
    let name: String
    var tournaments: [CalendarSource]
    var teams: [CalendarSource]
}

struct VCTData {
    var allVCTMatches: CalendarSource
    var regions: [RegionFeed]
}

enum HTMLBuilder {
    // Generates a single row
    static func node(name: String, fileName: String, level: Int) -> String {
        return #"""
        <div class="node level-\#(level)">
            <span class="label">\#(name)</span>
            <div class="links" data-file="\#(fileName)"></div>
        </div>
        """#
    }
    
    // Generates a block
    static func regionBlock(region: RegionFeed) -> String {
        let tourneyRows = region.tournaments.map { node(name: "🏆 \($0.name)", fileName: $0.fileName, level: 2) }.joined()
        let teamRows = region.teams.map { node(name: "🎮 \($0.name)", fileName: $0.fileName, level: 2) }.joined()
        
        return """
        <div class="category-header">\(region.name)</div>
        \(tourneyRows)
        \(teamRows)
        """
    }
    
    // Generates the whole page
    static func buildFullPage(data: VCTData) -> String {
        let allMatchesHTML = node(name: data.allVCTMatches.name, fileName: data.allVCTMatches.fileName, level: 1)
        let regionHTML = data.regions.map { regionBlock(region: $0) }.joined()
        
        return #"""
        <!DOCTYPE html>
        <html>
        \#(pageHeadHTML)
            <body>
        <div class="container">
            <header>
                <h1>VCT Calendar for upcoming matches</h1>
                <p class="subtitle">Click to subscribe to the respective calendar</p>
            </header>
        
            <div class="tree-root">
            <h1>VCT Calendar Hub</h1>
            \#(allMatchesHTML)
            \#(regionHTML)
            \#(pageScript)
        </div>
            </body>
        </html>
        """#
    }
    
    static let pageHeadHTML: String = """
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>VCT Calendar Hub</title>
        <style>
                :root {
                    --bg-color: #131314;
                    --card-bg: #1e1f20;
                    --text-main: #e3e3e3;
                    --text-dim: #b4b4b4;
                    --accent-blue: #8ab4f8;
                    --accent-green: #34a853; /* Added for 'Copied' feedback */
                    --border-color: #444746;
                    --hover-bg: #2b2c2f;
                }
    
                body {
                    background-color: var(--bg-color);
                    color: var(--text-main);
                    font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                    margin: 0;
                    padding: 40px 20px;
                    display: flex;
                    justify-content: center;
                }
    
                .container {
                    max-width: 800px;
                    width: 100%;
                }
    
                header {
                    margin-bottom: 40px;
                    border-bottom: 1px solid var(--border-color);
                    padding-bottom: 20px;
                }
    
                h1 { font-size: 2rem; font-weight: 500; margin: 0 0 10px 0; }
                .subtitle { color: var(--text-dim); font-size: 1.1rem; }
    
                .tree-root { list-style: none; padding: 0; }
                
                .node {
                    margin: 10px 0;
                    padding: 12px 16px;
                    background: var(--card-bg);
                    border: 1px solid var(--border-color);
                    border-radius: 8px;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    transition: background 0.2s;
                }
    
                .node:hover { background: var(--hover-bg); }
    
                .label { font-weight: 500; display: flex; align-items: center; gap: 10px; }
                
                .level-1 { margin-left: 0; border-left: 4px solid var(--accent-blue); }
                .level-2 { margin-left: 30px; border-color: #555; }
    
                .links { display: flex; gap: 10px; } /* Reduced gap slightly for 3 buttons */
    
                .btn {
                    text-decoration: none;
                    font-size: 0.8rem; /* Slightly smaller to fit 3 buttons */
                    padding: 6px 10px;
                    border-radius: 6px;
                    border: 1px solid transparent;
                    transition: all 0.2s;
                    cursor: pointer;
                    background: transparent;
                    white-space: nowrap;
                }
    
                .btn-google { color: var(--accent-blue); border-color: rgba(138, 180, 248, 0.3); }
                .btn-google:hover { background: rgba(138, 180, 248, 0.1); }
    
                .btn-apple { color: #fff; border-color: rgba(255, 255, 255, 0.2); }
                .btn-apple:hover { background: rgba(255, 255, 255, 0.1); }
    
                /* The New Copy Button Style */
                .btn-copy { color: var(--text-dim); border-color: var(--border-color); }
                .btn-copy:hover { border-color: var(--text-dim); background: rgba(255, 255, 255, 0.05); }
                .btn-copy.success { color: var(--accent-green); border-color: var(--accent-green); }
    
                .category-header {
                    color: var(--accent-blue);
                    text-transform: uppercase;
                    font-size: 0.75rem;
                    letter-spacing: 1.5px;
                    margin: 30px 0 10px 30px;
                }
            </style>
    </head>
    """
    static let pageScript = """
    <script>
        const BASE_URL = "raw.githubusercontent.com/chinhngoo/VLRCalendarGenerator/gh-pages/ics/";
    
        document.querySelectorAll('.links').forEach(div => {
            const fileName = div.getAttribute('data-file');
            const publicUrl = `https://${BASE_URL}${fileName}`;
            
            // 1. Google link
            const gLink = document.createElement('a');
            gLink.className = 'btn btn-google';
            gLink.href = `https://www.google.com/calendar/render?cid=webcal://${BASE_URL}${fileName}`;
            gLink.target = "_blank";
            gLink.innerText = "Google";
    
            // 2. Apple link
            const aLink = document.createElement('a');
            aLink.className = 'btn btn-apple';
            aLink.href = `webcal://${BASE_URL}${fileName}`;
            aLink.innerText = "Apple";
    
            // 3. Copy link (The New Addition)
            const cBtn = document.createElement('button');
            cBtn.className = 'btn btn-copy';
            cBtn.innerText = "Copy Link";
            cBtn.onclick = () => copyToClipboard(publicUrl, cBtn);
    
            div.appendChild(gLink);
            div.appendChild(aLink);
            div.appendChild(cBtn);
        });
    
        function copyToClipboard(text, btn) {
            navigator.clipboard.writeText(text).then(() => {
                const originalText = btn.innerText;
                btn.innerText = "Copied!";
                btn.classList.add('success');
                setTimeout(() => {
                    btn.innerText = originalText;
                    btn.classList.remove('success');
                }, 2000);
            });
        }
    </script>
    """
}
