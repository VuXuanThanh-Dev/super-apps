unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m com.opt,com.app && mkdir -p only && cp -r out/com.app only/ && java -p only -m com.app/com.app.Main
