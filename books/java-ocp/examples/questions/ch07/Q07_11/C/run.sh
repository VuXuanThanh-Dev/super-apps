unset JAVA_TOOL_OPTIONS
if javac -d out --module-source-path src -m com.shop >/dev/null 2>&1; then echo OK; else echo FAIL; fi
