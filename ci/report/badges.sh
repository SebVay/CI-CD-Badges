# fail if any commands fails
set -e
# make pipelines' return status equal the last command to exit with a non-zero status, or zero if all commands exit successfully
set -o pipefail
# debug log
set -x

source helper/functions.sh

COLOR_COVERAGE_PERFECT="#0EA5E9"
COLOR_COVERAGE_EXCELLENT="#16A34A"
COLOR_COVERAGE_VERY_GOOD="#22C55E"
COLOR_COVERAGE_GOOD="#84CC16"
COLOR_COVERAGE_FAIR="#EAB308"
COLOR_COVERAGE_MODERATE="#F59E0B"
COLOR_COVERAGE_BELOW_AVG="#F97316"
COLOR_COVERAGE_POOR="#EA270C"
COLOR_COVERAGE_BAD="#EF4444"
COLOR_DELTA_NEUTRAL="#BCBCBC"

# Internal
# Generates few JSON badge files with code coverage information for a specific module/project.
# Arguments:
#   $1: The name of the module to generate the badges for.
generateBadges() {
  local currentCoverage lastCoverage delta
  local path=$1

  generateDeltaBadges "$path"
  generateCurrentCommitBadge "$path"
}

calculateDelta() {
  awk -v val1="$1" -v val2="$2" 'BEGIN { print val1 - val2 }'
}

# Internal
# Creates a JSON badge file in the specified directory with coverage information.
# Arguments:
#   $1: Directory path where the badge file will be created
#   $2: Coverage percentage value
generateCurrentCommitBadge() {
  local cov color
  local path=$1
  local badgePath="$path/badges"
  mkdir -p "$badgePath"

  cov=$(metric "$path" coverage)

  if is "$cov" "==" 100; then color=$COLOR_COVERAGE_PERFECT
  elif is "$cov" ">=" 95; then color=$COLOR_COVERAGE_EXCELLENT
  elif is "$cov" ">=" 90; then color=$COLOR_COVERAGE_VERY_GOOD
  elif is "$cov" ">=" 80; then color=$COLOR_COVERAGE_GOOD
  elif is "$cov" ">=" 70; then color=$COLOR_COVERAGE_FAIR
  elif is "$cov" ">=" 60; then color=$COLOR_COVERAGE_MODERATE
  elif is "$cov" ">=" 50; then color=$COLOR_COVERAGE_BELOW_AVG
  elif is "$cov" ">=" 40; then color=$COLOR_COVERAGE_POOR
  else color=$COLOR_COVERAGE_BAD; fi

  cat <<EOF > "$badgePath/coverage.json"
{
  "schemaVersion": 1,
  "label": "Coverage",
  "message": "$cov%",
  "color": "$color"
}
EOF
}

# Internal
generateDeltaBadges() {
  local path=$1
  local pathBadge="$path/badges"
  local currentCoverage lastCoverage delta
  readarray -t csvLines < "$1/metrics.csv"

  csvSize=${#csvLines[@]}

  if [ "$csvSize" -gt 2 ]; then
    currentCoverage=$(metric "$path" coverage)
    lastCoverage=$(metric "$path" coverage -2)
    delta=$(calculateDelta "$currentCoverage" "$lastCoverage")

    generateDeltaBadge "$pathBadge" "deltaLastCommitCoverage" "$delta"
  fi

  if [ "$csvSize" -gt 11 ]; then
    currentCoverage=$(metric "$path" coverage)
    lastCoverage=$(metric "$path" coverage -11)
    delta=$(calculateDelta "$currentCoverage" "$lastCoverage")

    generateDeltaBadge "$pathBadge" "deltaLastTenCommitCoverage" "$delta"
  fi
}

# Internal
# Creates a JSON badge file in the specified directory with coverage delta from the last commit.
# Arguments:
#   $1: Directory path where the badge file will be created
#   $2: Badge identifier (JSON filename without extension)
#   $3: Coverage percentage delta value (change in coverage since last commit)
#   Returns: Creates a JSON badge file with color-coded delta visualization
generateDeltaBadge() {
  local color
  local delta=$3
  mkdir -p "$1"

  # add sign for positive deltas
  if is "$delta" ">" 0; then
    delta="+$delta"
  fi

  if is "$delta" ">=" 5; then color=$COLOR_COVERAGE_EXCELLENT
  elif is "$delta" ">=" 2; then color=$COLOR_COVERAGE_VERY_GOOD
  elif is "$delta" ">=" 1; then color=$COLOR_COVERAGE_GOOD
  elif is "$delta" ">=" 0; then color=$COLOR_DELTA_NEUTRAL
  elif is "$delta" ">" -1; then color=$COLOR_COLOR_COVERAGE_BELOW_AVG
  elif is "$delta" ">" -2; then color=$COLOR_COVERAGE_POOR
  elif is "$delta" ">" -5; then color=$COLOR_COVERAGE_VERY_BAD
  else color=$COLOR_COVERAGE_TERRIBLE; fi

  cat <<EOF > "$1/$2.json"
{
  "schemaVersion": 1,
  "label": "Δ",
  "message": "$delta%",
  "color": "$color"
}
EOF
}

# Public
# Processes a list of modules to generate coverage reports and badges.
# Arguments:
#   $@: Array of module names to process
generateBadgesForModulesAndProject() {
  local path=$1
  shift
  local modules=("$@")

  for module in "${modules[@]}"; do
    generateBadges "$path/$module"
  done

  generateBadges "$path"
}
