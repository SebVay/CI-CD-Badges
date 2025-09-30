# fail if any commands fails
set -e
# make pipelines' return status equal the last command to exit with a non-zero status, or zero if all commands exit successfully
set -o pipefail
# debug log
set -x

source helper/functions.sh

# Internal
# Generates a csv file with code coverage information for a specific module.
# Arguments:
#   $1: The name of the module to generate badge for.
generateMetricForModule() {
  local missed covered coverage
  local project=$1
  local module=$2
  local modulePath="$1/$2"

  read -r missed covered <<< "$(getMissedAndCoveredForModule "$module")"

  coverage=$(calcCoverage "$missed" "$covered")

  generateCsv "$modulePath" "$missed" "$covered" "$coverage"
}

# Internal
# Extracts missed and covered instruction counts from a JaCoCo test report XML file for a given module.
# Arguments:
#   $1: The name of the module to extract coverage data from
# Returns:
#   Two space-separated numbers: missed instructions count and covered instructions count
#   ex: "10 90"
getMissedAndCoveredForModule() {
  local reportCleansed missed covered
  local module=$1

  # Cleans all <package> tags in report
  reportCleansed=$(sed -E 's#<package[^>]*>.*?</package>##g' "../$module/build/reports/jacoco/test/jacocoTestReport.xml")

  missed=$(LC_ALL=C.UTF-8 grep -oP '<counter type="INSTRUCTION" missed="\K[0-9]+' <<< "$reportCleansed")
  covered=$(LC_ALL=C.UTF-8 grep -oP 'type="INSTRUCTION"[^>]*covered="\K[0-9]+' <<< "$reportCleansed")

  echo "$missed $covered"
}

# Internal
# Creates or appends to a CSV file containing code coverage metrics.
# Arguments:
#   $1: Directory path where the metrics.csv file will be created/updated
#   $2: Number of missed instructions
#   $3: Number of covered instructions
#   $4: Coverage percentage
# Side effects:
#   - Creates directory if it doesn't exist
#   - Creates metrics.csv with headers if it doesn't exist
#   - Appends a new row with coverage metrics, timestamp, and SHA
generateCsv() {
  local missed=$2
  local covered=$3
  local coverage=$4

  mkdir -p "$1"

  if ! [ -f "$1/metrics.csv" ]; then
    echo "missed,covered,coverage,timestamp,sha" >> "$1/metrics.csv"
  fi

  echo "$missed,$covered,$coverage,$(date +%s),$SHA" >> "$1/metrics.csv"
}

# Public
# Processes a list of modules to generate coverage reports and metrics.
# For each module and the overall project, creates or updates a metrics.csv file 
# containing code coverage data (missed instructions, covered instructions, coverage percentage).
# The CSV includes timestamps and commit SHA for historical tracking.
# Arguments:
#   $1: Project name/path where metrics will be stored
#   $@: Array of module names to process (after first argument)
generateMetrics() {
  local project=$1
  shift
  local modules=("$@")
  local totalMissed=0
  local totalCovered=0

  # Assigns only if SHA is not known
  : "${SHA:=sha_unset}"

  for module in "${modules[@]}"; do
    local missed covered
    local modulePath="$project/$module"

    generateMetricForModule "$project" "$module"

    totalMissed=$((totalMissed + $(metric "$modulePath" missed)))
    totalCovered=$((totalCovered + $(metric "$modulePath" covered)))
  done

  generateCsv "$project" "$totalMissed" "$totalCovered" "$(calcCoverage "$totalMissed" "$totalCovered")"
}
