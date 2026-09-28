unset JAVA_TOOL_OPTIONS
javac -d out Main.java && cp *.properties out/ && java -cp out Main
