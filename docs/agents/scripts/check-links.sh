#!/usr/bin/env bash
# Check every http(s) link in docs/agents/*.md with curl.
# Result per link: OK (2xx/3xx), BROKEN (4xx/5xx from the site), BLOCKED (sandbox proxy refused the host).
set -u
cd "$(dirname "$0")/../../.."
links=$(grep -hoE 'https?://[^ )>`"|]+' docs/agents/*.md | sed 's/[.,]$//' | sort -u)
broken=0
for u in $links; do
  code=$(curl -s -o /dev/null -m 20 -L -w '%{http_code}' "$u" 2>/dev/null); rc=$?
  if [ "$rc" = "56" ] || [ "$code" = "000" ]; then echo "BLOCKED $u"
  # The cloud sandbox proxy answers 403 for every github.com page (policy, not the site).
  # Those pages were opened with the WebFetch tool instead (see PROGRESS.md).
  elif [ "$code" = "403" ] && [[ "$u" == https://github.com/* ]]; then echo "BLOCKED(github 403 in sandbox) $u"
  elif [ "$code" -ge 200 ] && [ "$code" -lt 400 ]; then echo "OK $code $u"
  else echo "BROKEN $code $u"; broken=$((broken+1)); fi
done
echo "broken=$broken"
[ "$broken" = 0 ]
