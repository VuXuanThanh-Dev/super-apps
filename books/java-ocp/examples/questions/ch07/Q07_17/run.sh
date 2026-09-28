unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m mod.a,mod.b 2>&1 | grep -o "cyclic dependence" | head -1
