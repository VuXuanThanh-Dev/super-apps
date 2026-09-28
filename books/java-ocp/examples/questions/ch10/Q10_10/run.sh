unset JAVA_TOOL_OPTIONS
javac -d out Prices.java Prices_vi.java Main.java && cp Prices_vi.properties out/ && java -cp out Main
