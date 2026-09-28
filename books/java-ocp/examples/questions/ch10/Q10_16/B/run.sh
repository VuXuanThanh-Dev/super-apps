unset JAVA_TOOL_OPTIONS
javac -d out Main.java 2>/dev/null && cp *.properties out/ && java -cp out Main
