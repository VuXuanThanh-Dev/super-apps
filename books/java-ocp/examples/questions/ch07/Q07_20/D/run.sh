unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m com.app
jlink -p out -m com.app --output image >/dev/null 2>&1
image/bin/java -m com.app/com.app.Main 2>/dev/null
