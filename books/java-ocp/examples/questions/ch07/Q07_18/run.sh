unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m com.q && java -p out -m com.q/com.q.Main
