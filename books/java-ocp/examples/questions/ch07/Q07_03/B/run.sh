unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m m.one,m.two && java -p out -m m.two/shared.B 2>&1 | grep -o "LayerInstantiationException: Package shared in both module" | head -1
