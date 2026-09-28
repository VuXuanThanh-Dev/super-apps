unset JAVA_TOOL_OPTIONS
javac -d mods --module-source-path src -m com.x
java -m mods/com.x/com.x.Main 2>/dev/null
