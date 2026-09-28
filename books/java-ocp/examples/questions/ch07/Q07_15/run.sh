unset JAVA_TOOL_OPTIONS
for m in com.friend com.other; do
  if javac -d out-$m --module-source-path src -m com.core,$m >/dev/null 2>&1; then echo "$m OK"; else echo "$m FAIL"; fi
done
