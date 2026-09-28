unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m com.app && jlink --module-path out --add-modules com.app --output image && image/bin/java --list-modules | sed 's/@.*//' | tr '\n' ' '
