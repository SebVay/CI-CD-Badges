set -euxo pipefail

# Make the script execute regardless of the caller current path by
# changing the current working directory to the script's own directory.
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source clean/remove_outdated_files.sh
source metrics/metrics.sh
source report/badges.sh
source report/html.sh

project=$1
shift
modules=("$@")

# Moving out of /ci, now we are operating at project's root
cd ..

removeOutdatedFiles "$project" "${modules[@]}"
generateMetrics "$project" "${modules[@]}"
generateBadgesForModulesAndProject "$project" "${modules[@]}"
generateHtmlPage "$project" "${modules[@]}"
