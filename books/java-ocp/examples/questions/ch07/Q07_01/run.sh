unset JAVA_TOOL_OPTIONS
javac -d out --module-source-path src -m com.lib,com.app 2>&1 | grep -o "package com.lib.impl is not visible" | head -1
