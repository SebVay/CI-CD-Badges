# fail if any commands fails
set -e
# make pipelines' return status equal the last command to exit with a non-zero status, or zero if all commands exit successfully
set -o pipefail
# debug log
set -x

# Internal
# Copies JaCoCo coverage reports from a module's build directory to a CICD directory.
# Arguments:
#   $1: The name of the module to copy reports from
copyJacocoReportForModule() {
  local project=$1
  local module=$2
  local modulePath="$project/$module"

  mkdir -p "$modulePath/jacoco"
  cp -rp "../$module/build/reports/jacoco" "$modulePath"
}

# Public
# Processes a list of modules to copy their JaCoCo coverage reports to the CICD directory.
# For each module, creates a directory structure and copies the JaCoCo reports
# from the module's build directory to the specified project path.
# Arguments:
#   $1: Project name/path where reports will be stored
#   $@: Array of module names to process (after first argument)
generateJacocoReport() {
  local project=$1
  shift
  local modules=("$@")
  for module in "${modules[@]}"; do
    copyJacocoReportForModule "$project" "$module"
  done
}