unset JAVA_TOOL_OPTIONS
javac -d mods --module-source-path src -m com.x
java -p mods -m com.x/com.x.Main 2>/dev/null
