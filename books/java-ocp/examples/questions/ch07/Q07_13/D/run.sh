unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m com.solo && jar --create --file solo.jar -C out/com.solo . && java -cp solo.jar com.solo.Main
