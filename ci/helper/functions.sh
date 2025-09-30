# Compares two values using a specified operator.
# Arguments:
#   $1: First value to compare
#   $2: Operator to use (e.g. "==", ">=", ">", etc.)
#   $3: Second value to compare
is() {
  awk -v a="$1" -v op="$2" -v b="$3" '
    BEGIN {
      # Coerce to numbers to handle numeric strings (+0, 0.0, etc.)
      if (op == "==")      exit !(a == b)
      else if (op == "!=") exit !(a != b)
      else if (op == ">")  exit !(a >  b)
      else if (op == ">=") exit !(a >= b)
      else if (op == "<")  exit !(a <  b)
      else if (op == "<=") exit !(a <= b)
      else { print "Unsupported operator"; exit 2 }
    }
  '
}

# Extracts a specific metric value from a metrics CSV file.
# Arguments:
#   $1: The name of the metric to extract (e.g., coverage, missed, covered)
#   $2: Path to the module directory containing metrics.csv
# Returns:
#   The value for the requested metric from the first matching headerRow
metric() {
  local file="$1/metrics.csv"
  local columnName=$2
  local lineToLookFor=${3--1}
  readarray -t csvLines < "$file"

  headerRow="${csvLines[0]}"
  column=$(positionOf "$headerRow" "$columnName") || exit 1

  lastLine="${csvLines[$lineToLookFor]}"

  IFS=',' read -ra lastLine <<< "$lastLine"

  echo "${lastLine[$column]}"
}

# Helper function to find the position of a column name in a comma-separated headerRow.
# Arguments:
#   $1: A comma-separated headerRow string to search in
#   $2: The name of the column to find
# Returns:
#   The zero-based index position of the target column name if found
#   Returns 1 if column name is not found
positionOf() {
  IFS=',' read -ra headerRow <<< "$1"

  target="$2"
  for index in "${!headerRow[@]}"; do
    if [[ ${headerRow[index]} == "$target" ]]; then
      echo "$index"
      return 0
    fi
  done
  echo "positionOf() didn't find '$2' in '$1'"
  return 1
}

# Calculates the coverage percentage based on missed and covered instructions.
# It takes two arguments:
# $1: The number of missed instructions.
# $2: The number of covered instructions.
# Example: coverage_calc 10 90  => 88.8
calcCoverage() {
  awk "BEGIN { print int(((1 - ($1 / $2)) * 100) * 10) / 10 }"
}