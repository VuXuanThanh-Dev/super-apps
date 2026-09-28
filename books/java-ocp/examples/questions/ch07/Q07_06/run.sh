unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m com.api,com.app && java -p out -m com.app/com.app.Main 2>&1 | grep -o "java.util.ServiceConfigurationError" | head -1
