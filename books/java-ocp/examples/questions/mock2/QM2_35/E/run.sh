unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m com.run
mkdir -p mods
jar --create --file mods/run.jar --main-class com.run.Main out/com.run >/dev/null 2>&1
java -p mods -m com.run 2>/dev/null
