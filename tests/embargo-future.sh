#!/usr/bin/env bash
# Regressão: artigos com data futura têm página "em construção" sem vazar o corpo; após site.time >= date, artigo real.
set -euo pipefail

export PATH="/usr/bin:/bin:${PATH}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fx=tests/fixtures
build() {
  bundle exec jekyll build --config "_config.yml,$1" -d "$2" >/dev/null
}

assert_em_construcao() {
  local html="$1"
  grep -q 'em-construcao' "$html"
  grep -qi 'em construção' "$html"
  grep -qi 'noindex' "$html"
}

assert_no_markers_in() {
  local file="$1"
  shift
  local m
  for m in "$@"; do
    if grep -qF "$m" "$file"; then
      echo "FAIL: marcador de corpo vazou em $file: $m"
      exit 1
    fi
  done
}

echo "Checagem: stubs agendados"
./scripts/sync-scheduled-artigos.sh --check

echo "Caso 1: agora (antes das datas futuras) — placeholder, sem corpo"
build "_config.yml" "_site_embargo_now"
for slug in binance-ataque-hot-wallet-2026 jepsen-particledb-testes-e-llms sre-deskilling-squad-de-agentes mercado-bitcoin-ataque-hot-wallet-2026; do
  f="_site_embargo_now/artigos/${slug}.html"
  if [[ ! -f "$f" ]]; then echo "FAIL: falta $f"; exit 1; fi
  assert_em_construcao "$f"
done

assert_no_markers_in "_site_embargo_now/artigos/binance-ataque-hot-wallet-2026.html" \
  "Quando leio um post-mortem de exchange" \
  "Richard Teng rejeitou a leitura"
assert_no_markers_in "_site_embargo_now/artigos/jepsen-particledb-testes-e-llms.html" \
  "Kyle Kingsbury analisou"
assert_no_markers_in "_site_embargo_now/artigos/mercado-bitcoin-ataque-hot-wallet-2026.html" \
  "Segundo o comunicado do Mercado Bitcoin"

echo "Caso 2: fronteira America/Sao_Paulo — SRE (2026-11-10 00:00:00 -0300)"
cat > /tmp/embargo-before-sre.yml <<'EOF'
time: 2026-11-09 23:59:59 -0300
EOF
build "_config.yml,/tmp/embargo-before-sre.yml" "_site_embargo_before_sre"
assert_em_construcao "_site_embargo_before_sre/artigos/sre-deskilling-squad-de-agentes.html"

cat > /tmp/embargo-after-sre.yml <<'EOF'
time: 2026-11-10 00:00:00 -0300
EOF
build "_config.yml,/tmp/embargo-after-sre.yml" "_site_embargo_after_sre"
if grep -q 'em-construcao' "_site_embargo_after_sre/artigos/sre-deskilling-squad-de-agentes.html"; then
  echo "FAIL: artigo SRE ainda em construção após data de publicação"
  exit 1
fi
grep -q 'Lisanne Bainbridge' "_site_embargo_after_sre/artigos/sre-deskilling-squad-de-agentes.html" || {
  echo "FAIL: corpo do artigo SRE ausente após publicação"
  exit 1
}

echo "Caso 3: post-mortem futuro não vaza corpo no HTML"
cat > postmortems/ci-pm-future-embargo.md <<'EOF'
---
title: "PM-9004 — fixture embargo"
pm_id: PM-9004
date: 2099-03-01 00:00:00 -0300
layout: postmortem
type: postmortem
summary: Fixture embargo PM.
permalink: /postmortems/ci-pm-future-embargo.html
---
# Corpo secreto embargo PM SECRETEMBARGO999
EOF
cleanup() { rm -f postmortems/ci-pm-future-embargo.md; }
trap cleanup EXIT
build "_config.yml" "_site_embargo_pm"
html="_site_embargo_pm/postmortems/ci-pm-future-embargo.html"
test -f "$html"
assert_em_construcao "$html"
if grep -q 'SECRETEMBARGO999' "$html"; then
  echo "FAIL: corpo do PM futuro vazou no HTML"
  exit 1
fi

echo "OK"
