# fail if any commands fails
set -e
# make pipelines' return status equal the last command to exit with a non-zero status, or zero if all commands exit successfully
set -o pipefail
# debug log
set -x

generateHtmlPage() {
  local project=$1
  shift
  local modules=("$@")
  local table_rows=""

  for module in "${modules[@]}"; do
    local badgeUrl="https://raw.githubusercontent.com/SebVay/CI-CD-Badges/refs/heads/main/$project/$module/badges/coverage.json"
    local coverageBadgeUrl="https://img.shields.io/endpoint?url=$badgeUrl"
    local jacocoUrl="https://sebvay.github.io/CI-CD-Badges/$project/$module/jacoco/test/html"
    local htmlImgTag="<a href=\"$jacocoUrl\"><img src=\"$coverageBadgeUrl\" alt=\"Coverage Badge\"/></a>"

    table_rows+="<tr><td>$module</td><td>$htmlImgTag</td></tr>"
  done

  local totalBadgeUrl="https://raw.githubusercontent.com/SebVay/CI-CD-Badges/refs/heads/main/$project/badges/coverage.json"
  local totalCoverageBadgeUrl="https://img.shields.io/endpoint?url=$totalBadgeUrl"
  local totalHtmlImgTag="<img src=\"$totalCoverageBadgeUrl\" alt=\"Total Project Coverage\"/>"

  local lastCommitImgTag="<img src=\"https://img.shields.io/badge/last%20commit%20coverage-pending-9ca3af\" alt=\"Since last commit coverage delta\" />"

  cat <<EOF > "$project/index.html"
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Code Coverage Report</title>
    <style>
      :root {
        --bg: #0f172a;          /* slate-900 */
        --panel: #111827;       /* gray-900 */
        --panel-2: #0b1220;     /* darker */
        --text: #e5e7eb;        /* gray-200 */
        --muted: #9ca3af;       /* gray-400 */
        --accent: #22c55e;      /* green-500 */
        --accent-2: #16a34a;    /* green-600 */
        --border: #1f2937;      /* gray-800 */
        --headerRow: #0b1220;         /* alt headerRow */
      }
      * { box-sizing: border-box; }
      body {
        margin: 0;
        font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, "Apple Color Emoji", "Segoe UI Emoji";
        background: radial-gradient(1200px 800px at 10% -10%, #11213a 10%, transparent 60%),
                    radial-gradient(1000px 700px at 110% 10%, #132238 10%, transparent 60%), var(--bg);
        color: var(--text);
        min-height: 100vh;
        display: flex;
        align-items: center;
      }
      .container {
        width: 100%;
        max-width: 980px;
        margin: 48px auto;
        padding: 24px;
        background: linear-gradient(180deg, var(--panel), var(--panel-2));
        border: 1px solid var(--border);
        border-radius: 16px;
        box-shadow: 0 10px 30px rgba(0,0,0,.35), inset 0 1px 0 rgba(255,255,255,.02);
      }
      header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        margin-bottom: 18px;
      }
      h1 {
        font-size: 24px;
        margin: 0;
        letter-spacing: .3px;
      }
      .subtitle {
        color: var(--muted);
        font-size: 14px;
        margin: 0 0 20px 0;
      }
      .badges {
        display: flex;
        align-items: center;
        gap: 10px;
      }
      table {
        width: 100%;
        border-collapse: collapse;
        overflow: hidden;
        border: 1px solid var(--border);
        border-radius: 12px;
        background: rgba(17,24,39,.6);
      }
      thead th {
        text-align: left;
        padding: 12px 14px;
        font-weight: 600;
        font-size: 13px;
        color: var(--muted);
        background: rgba(31,41,55,.6);
        border-bottom: 1px solid var(--border);
      }
      tbody td {
        padding: 12px 14px;
        border-bottom: 1px solid var(--border);
        vertical-align: middle;
        font-size: 14px;
      }
      tbody tr:nth-child(odd) { background: rgba(2,6,23,.35); }
      tbody tr:hover { background: rgba(34,197,94,.08); }
      .module-name { font-weight: 600; }
      /* Center the Coverage column (header and cells) */
      thead th:nth-child(2),
      tbody td:nth-child(2) {
        text-align: right;
      }
      .total-coverage {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        margin-top: 22px;
        padding: 14px 16px;
        background: linear-gradient(180deg, rgba(34,197,94,.12), rgba(34,197,94,.06));
        border: 1px solid rgba(34,197,94,.2);
        border-radius: 12px;
      }
      .total-coverage h3 {
        margin: 0;
        font-size: 16px;
        color: #bbf7d0; /* green-200 */
        letter-spacing: .2px;
      }
      a { color: inherit; text-decoration: none; }
      .footer {
        margin-top: 14px;
        padding-top: 0;
        color: var(--muted);
        font-size: 13px;
        line-height: 1.5;
      }
      .footer a { color: #93c5fd; text-decoration: underline; }
      /* Separator between sections */
      .section-separator { margin: 18px 0 14px; height: 1px; background: linear-gradient(90deg, transparent, var(--border), transparent); }
      /* Delta/Trends sections */
      .delta-sections { margin-top: 22px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; }
      @media (max-width: 720px) { .delta-sections { grid-template-columns: 1fr; } }
      .delta-card { padding: 14px 16px; background: rgba(17,24,39,.6); border: 1px solid var(--border); border-radius: 12px; }
      .delta-card h4 { margin: 0 0 10px 0; font-size: 15px; color: var(--text); letter-spacing: .2px; }
      .delta-badges { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; }
    </style>
  </head>
  <body>
    <div class="container">
      <header>
        <h1>Code Coverage</h1>
        <div class="badges">
          <!-- space for future badges -->
        </div>
      </header>
      <p class="subtitle">Generated report with per-module coverage and links to JaCoCo HTML.</p>
      <table>
        <thead>
          <tr>
            <th>Module</th>
            <th>Coverage</th>
          </tr>
        </thead>
        <tbody>
          $table_rows
        </tbody>
      </table>
      <div class="total-coverage">
        <h3>Total Project Coverage</h3>
        $totalHtmlImgTag
      </div>
      <div class="section-separator" aria-hidden="true"></div>
      <!-- Trends / Delta sections  -->
      <div class="delta-sections">
        <div class="delta-card">
          <h4>Since last commit</h4>
          <div class="delta-badges">
            $lastCommitImgTag
          </div>
        </div>
        <div class="delta-card">
          <h4>Since last 5 commits</h4>
          <div class="delta-badges">
            <img src="https://img.shields.io/badge/coverage%20delta-pending-9ca3af" alt="Since last 5 commits coverage delta" />
          </div>
        </div>
        <div class="delta-card">
          <h4>Since last week</h4>
          <div class="delta-badges">
            <img src="https://img.shields.io/badge/coverage%20delta-pending-9ca3af" alt="Since last week coverage delta" />
          </div>
        </div>
        <div class="delta-card">
          <h4>Since last month</h4>
          <div class="delta-badges">
            <img src="https://img.shields.io/badge/coverage%20delta-pending-9ca3af" alt="Since last month coverage delta" />
          </div>
        </div>
      </div>
      <div class="section-separator" aria-hidden="true"></div>
      <div class="footer">Built with a few simple scripts (Bash + JaCoCo + shields.io).<br> If you'd like the snippets that generate this page and the badges, drop me a line at <a href="mailto:sebast.mar@gmail.com">sebast.mar@gmail.com</a>.</div>
    </div>
  </body>
</html>
EOF
}