unset JAVA_TOOL_OPTIONS
javac -d lib-out lib/org/a/A.java lib/org/b/B.java && mkdir -p mods && jar --create --file mods/twopkg.jar -C lib-out .
javac -p mods -d out --module-source-path src -m com.use && java -p mods:out -m com.use/com.use.Main
