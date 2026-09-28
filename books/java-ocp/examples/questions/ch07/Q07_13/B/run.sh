unset JAVA_TOOL_OPTIONS
javac -d cp-out lib/org/cp/Helper.java
javac -cp cp-out -d out --module-source-path src -m com.named 2>&1 | grep -o "package org.cp does not exist" | head -1
