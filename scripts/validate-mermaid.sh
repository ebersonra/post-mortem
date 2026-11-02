#!/usr/bin/env bash
# Extracts every mermaid block (``` or ~~~ fences, optionally indented) from the
# Markdown content and renders it with mermaid-cli pinned in tools/mermaid
# (mermaid overridden to the same version as _includes/head-custom.html).
# Fails if no block is found, if the extracted count differs from the number of
# opening fences, if a block is left unclosed, or if any block fails to render.
#
# Usage: scripts/validate-mermaid.sh [dir ...]   (default: postmortems _articles, plus _posts if present)
# Requires: npm ci --ignore-scripts in tools/mermaid, and a Chrome binary in
# PUPPETEER_EXECUTABLE_PATH (CI uses the runner's /usr/bin/google-chrome).
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tooldir="$root/tools/mermaid"
if [ ! -x "$tooldir/node_modules/.bin/mmdc" ]; then
  echo "mmdc não instalado: rode 'npm ci --ignore-scripts' em tools/mermaid" >&2
  exit 1
fi

# Default: postmortems/ and _articles/ are required, _posts/ is optional.
# Explicit dirs (used by the self-tests) are all required.
if [ "$#" -gt 0 ]; then required=("$@"); optional=(); else required=(postmortems _articles); optional=(_posts); fi
dirs=()
for d in "${required[@]}"; do
  if [ -d "$d" ]; then dirs+=("$d"); else echo "Diretório obrigatório ausente: $d" >&2; exit 1; fi
done
for d in "${optional[@]+"${optional[@]}"}"; do
  if [ -d "$d" ]; then dirs+=("$d"); else echo "aviso: diretório opcional ausente, ignorado: $d" >&2; fi
done

out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT
# --no-sandbox: only acceptable on ephemeral GitHub-hosted runners (ubuntu-latest),
# where Chrome's sandbox is blocked by AppArmor, the rendered content comes from
# this repo and the token is read-only. Do NOT reuse this on a self-hosted runner.
printf '{"args":["--no-sandbox"]}' > "$out/puppeteer.json"

opening='^[[:space:]]*(```|~~~)[[:space:]]*mermaid[[:space:]]*$'
files=()
while IFS= read -r f; do files+=("$f"); done < <(find "${dirs[@]}" -name '*.md' -type f | sort)

expected=0
for f in "${files[@]}"; do
  n="$(grep -cE "$opening" "$f" || true)"
  expected=$((expected + n))
  base="$(echo "$f" | tr '/' '_')"
  if ! awk -v out="$out" -v base="$base" -v src="$f" '
    !inb && match($0, /^[[:space:]]*(```|~~~)[[:space:]]*mermaid[[:space:]]*$/) {
      inb = 1; n++; start = FNR
      indent = $0; sub(/[^[:space:]].*$/, "", indent)
      fence = $0; sub(/^[[:space:]]*/, "", fence); fence = substr(fence, 1, 3)
      file = out "/" base "__" n ".mmd"; printf "" > file; next
    }
    inb {
      line = $0; t = line; sub(/^[[:space:]]*/, "", t)
      if (index(t, fence) == 1 && t ~ /^(```+|~~~+)[[:space:]]*$/) { inb = 0; close(file); next }
      if (indent != "" && index(line, indent) == 1) line = substr(line, length(indent) + 1)
      print line > file
    }
    END { if (inb) { printf "Bloco mermaid sem fechamento em %s (linha %d)\n", src, start > "/dev/stderr"; exit 1 } }
  ' "$f"; then
    exit 1
  fi
done

shopt -s nullglob
blocks=("$out"/*.mmd)
count="${#blocks[@]}"
if [ "$count" -eq 0 ]; then echo "Nenhum bloco mermaid encontrado" >&2; exit 1; fi
if [ "$count" -ne "$expected" ]; then
  echo "Extraídos $count blocos, mas há $expected cercas de abertura mermaid" >&2; exit 1
fi

failed=""
for m in "${blocks[@]}"; do
  if (cd "$tooldir" && npx --no-install mmdc -p "$out/puppeteer.json" -q -i "$m" -o "${m%.mmd}.svg") >"$m.log" 2>&1; then
    echo "OK   $(basename "$m")"
  else
    echo "FAIL $(basename "$m")"; sed 's/^/     /' "$m.log" | head -20
    failed="$failed $(basename "$m")"
  fi
done
echo "Blocos mermaid validados: $count (mermaid $(cd "$tooldir" && node -p 'require("mermaid/package.json").version'))"
if [ -n "$failed" ]; then echo "Blocos com erro:$failed"; exit 1; fi
