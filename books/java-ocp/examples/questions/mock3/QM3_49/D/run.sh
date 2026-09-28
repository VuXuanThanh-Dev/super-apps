unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m com.v && mkdir -p mods && jar --create --file mods/x.jar -C out/com.v .
jar --list --file mods/x.jar 2>/dev/null | head -1 | grep -v "not found" | cut -d' ' -f1
