# fail if any commands fails
set -e
# make pipelines' return status equal the last command to exit with a non-zero status, or zero if all commands exit successfully
set -o pipefail
# debug log
set -x

# Internal
# Removes generated report files, metrics and directories from a specified module directory.
# Arguments:
#   $1: Path to the module directory containing generated files
deleteGeneratedFiles() {
    rm -rf "$1/badges" "$1/jacoco" "$1/index.html"
}

# Public
# Removes generated files from all specified modules and the parent project directory.
# Updates Git index with all deletions.
# Arguments:
#   $@: Array of module names to clean
removeOutdatedFiles() {
  local project=$1
  shift
  local modules=("$@")

  for module in "${modules[@]}"; do
    deleteGeneratedFiles "$project/$module"
  done

  deleteGeneratedFiles "$project"

  git add -u
}