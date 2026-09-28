unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m m.model,m.user && java -p out -m m.user/m.user.Main
