unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m m.plain && java -p out --describe-module m.plain | grep mandated
