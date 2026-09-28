unset JAVA_TOOL_OPTIONS
javac -d out Main.java && cp B.properties out/ && java -cp out Main
