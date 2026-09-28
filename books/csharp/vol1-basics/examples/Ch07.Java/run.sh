#!/usr/bin/env bash
set -e
unset JAVA_TOOL_OPTIONS   # sandbox proxy settings, not needed here
echo '$ java --version'
java --version | head -1
echo '$ java Compare.java'
java -Dstdout.encoding=UTF-8 Compare.java
