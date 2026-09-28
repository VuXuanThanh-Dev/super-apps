unset JAVA_TOOL_OPTIONS
if javac -d out --module-source-path src -m com.api,com.impl,com.app >/dev/null 2>&1; then
  java -p out -m com.app/com.app.Main
else
  echo "compile error"
fi
