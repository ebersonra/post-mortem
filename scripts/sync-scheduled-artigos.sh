#!/usr/bin/env bash
# Gera ou valida páginas "em construção" para artigos com data futura (embargo Jekyll future: false).
# Comparação de datas em America/Sao_Paulo (via site.time do Jekyll / TZ abaixo para "agora").
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARTICLES="$ROOT/_articles"
OUT="$ROOT/scheduled-artigos"
MODE=write
if [[ "${1:-}" == "--check" ]]; then
  MODE=check
fi

export TZ=America/Sao_Paulo
now_epoch="$(date +%s)"

yaml_field() {
  local file="$1" key="$2"
  awk -v k="$key" '
    NR==1 { if ($0 != "---") exit 1; next }
    $0 == "---" { exit }
    $0 ~ "^" k ":" {
      sub("^" k ":[[:space:]]*", "")
      gsub(/^["'\'']|["'\'']$/, "")
      print
      exit
    }
  ' "$file"
}

is_future_date() {
  local raw="$1"
  local epoch
  epoch=$(date -d "$raw" +%s 2>/dev/null) || return 1
  [[ "$epoch" -gt "$now_epoch" ]]
}

mkdir -p "$OUT"
want_list="$(mktemp)"
trap 'rm -f "$want_list"' EXIT

shopt -s nullglob
for f in "$ARTICLES"/*.md; do
  base="$(basename "$f" .md)"
  date_raw="$(yaml_field "$f" date || true)"
  published="$(yaml_field "$f" published || true)"
  if [[ "$published" == "false" ]]; then
    continue
  fi
  if [[ -z "$date_raw" ]]; then
    continue
  fi
  if ! is_future_date "$date_raw"; then
    continue
  fi
  title="$(yaml_field "$f" title || true)"
  description="$(yaml_field "$f" description || true)"
  if [[ -z "$title" ]]; then
    echo "FAIL: $f sem title para stub agendado" >&2
    exit 1
  fi
  printf '%s\n' "$base" >>"$want_list"
  dest="$OUT/$base.md"
  esc_title=$(printf '%s' "$title" | sed 's/\\/\\\\/g; s/"/\\"/g')
  esc_desc=$(printf '%s' "$description" | sed 's/\\/\\\\/g; s/"/\\"/g')
  body="---
layout: em-construcao
title: \"${esc_title}\"
description: \"${esc_desc}\"
permalink: /artigos/${base}.html
article_slug: ${base}
publish_after: ${date_raw}
type: article
robots: noindex, nofollow
sitemap: false
---"
  if [[ "$MODE" == check ]]; then
    if [[ ! -f "$dest" ]]; then
      echo "FAIL: falta stub agendado $dest (artigo futuro $f)" >&2
      exit 1
    fi
    if ! grep -q "publish_after: ${date_raw}" "$dest"; then
      echo "FAIL: publish_after desatualizado em $dest (esperado ${date_raw})" >&2
      exit 1
    fi
  else
    printf '%s\n' "$body" >"$dest"
  fi
done

for stub in "$OUT"/*.md; do
  [[ -e "$stub" ]] || continue
  base="$(basename "$stub" .md)"
  if ! grep -qxF "$base" "$want_list" 2>/dev/null; then
    if [[ "$MODE" == check ]]; then
      # Stubs órfãos após publicação não quebram o site (o artigo prevalece), mas mantemos o diretório limpo.
      if [[ -f "$ARTICLES/$base.md" ]]; then
        echo "FAIL: stub órfão $stub — rode scripts/sync-scheduled-artigos.sh" >&2
        exit 1
      fi
    else
      rm -f "$stub"
    fi
  fi
done

if [[ "$MODE" == "check" ]]; then
  echo "OK: stubs de artigos futuros sincronizados"
fi
