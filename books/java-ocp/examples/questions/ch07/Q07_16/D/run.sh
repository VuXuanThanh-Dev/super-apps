unset JAVA_TOOL_OPTIONS
javac --module-source-path src -d out $(find src -name '*.java') >/dev/null 2>&1
java -p out -m com.x/com.x.Main 2>/dev/null
