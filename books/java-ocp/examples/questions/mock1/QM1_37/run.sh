unset JAVA_TOOL_OPTIONS
javac -d c lib/org/apache/commons/text/Words.java && jar --create --file commons-text-1.10.0.jar --manifest manifest.txt -C c . && jar --describe-module --file commons-text-1.10.0.jar | grep automatic | grep -v "No module"
