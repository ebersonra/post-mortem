#!/usr/bin/env bash
# Extracts every ```mermaid block from Markdown content and renders it with the
# real mermaid parser (mermaid-cli). Fails if any block does not render.
set -euo pipefail
MMDC_VERSION="${MMDC_VERSION:-11.17.1}"
out="$(mktemp -d)"
printf '{"args":["--no-sandbox"]}' > "$out/puppeteer.json"
count=0; failed=""
while IFS= read -r -d '' f; do
  awk -v out="$out" -v base="$(echo "$f" | tr '/' '_')" '
    /^```mermaid[[:space:]]*$/ {inb=1; n++; file=out "/" base "__" n ".mmd"; next}
    inb && /^```[[:space:]]*$/ {inb=0; close(file); next}
    inb {print > file}
  ' "$f"
done < <(find postmortems _articles _posts -name '*.md' -print0 2>/dev/null)
for m in "$out"/*.mmd; do
  [ -e "$m" ] || continue
  count=$((count+1))
  if npx -y "@mermaid-js/mermaid-cli@${MMDC_VERSION}" -p "$out/puppeteer.json" -q -i "$m" -o "${m%.mmd}.svg" >"$m.log" 2>&1; then
    echo "OK   $(basename "$m")"
  else
    echo "FAIL $(basename "$m")"; sed 's/^/     /' "$m.log" | head -20
    failed="$failed $(basename "$m")"
  fi
done
echo "Blocos mermaid validados: $count"
if [ -n "$failed" ]; then echo "Blocos com erro:$failed"; exit 1; fi
