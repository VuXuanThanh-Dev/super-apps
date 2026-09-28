unset JAVA_TOOL_OPTIONS
javac -d out Main.java && cp K.properties out/ && java -cp out Main
