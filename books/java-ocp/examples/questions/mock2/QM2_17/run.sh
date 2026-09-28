unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m com.m,com.fw,com.other && java -p out -m com.fw/com.fw.Main && java -p out -m com.other/com.other.Main
