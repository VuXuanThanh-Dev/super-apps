# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
