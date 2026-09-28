unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src com.x >/dev/null 2>&1
java -p out -m com.x/com.x.Main 2>/dev/null
