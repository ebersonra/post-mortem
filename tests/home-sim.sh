#!/usr/bin/env bash
# Simula a home com fixtures de datas controladas (ver #20). Não depende do conteúdo real:
# site.time é fixado em 2099-12-31 e as fixtures são mais novas que qualquer publicação real.
set -euo pipefail
trap 'rm -f _articles/ci-flood-*.md postmortems/ci-pm-*.md' EXIT
fx=tests/fixtures
cards() { grep -o 'post-card__title"><a href="[^"]*"' "$1" | sed 's/.*href="//;s/"$//'; }
build() { bundle exec jekyll build --config "_config.yml,$fx/home-sim/_config.ci-sim.yml" -d "$1" >/dev/null; }

mkdir -p _articles
cp "$fx"/home-sim/ci-flood-*.md _articles/
cp "$fx/postmortems/ci-pm-latest.md" "$fx/postmortems/ci-pm-future.md" postmortems/

echo "Caso A: top 8 só com artigos -> 8º card vira o PM mais recente (não futuro)"
build _site_sim_a
h=_site_sim_a/index.html
test "$(cards "$h" | wc -l)" -eq 8
test "$(cards "$h" | sort | uniq -d | wc -l)" -eq 0
test "$(grep -c 'post-card__type">Post-mortem' "$h")" -eq 1
test "$(grep -c 'post-card__type">Artigo' "$h")" -eq 7
cards "$h" | tail -1 | grep -q '/postmortems/ci-pm-latest'
if grep -q 'ci-pm-future' "$h"; then echo "FAIL: ci-pm-future não deveria aparecer na home"; exit 1; fi
cards "$h" | head -1 | grep -q '/artigos/ci-flood-9'

echo "Caso B: PM já está no top 8 -> home inalterada, sem PM extra"
cp "$fx/postmortems/ci-pm-in-top8.md" postmortems/
build _site_sim_b
h=_site_sim_b/index.html
test "$(cards "$h" | wc -l)" -eq 8
test "$(cards "$h" | sort | uniq -d | wc -l)" -eq 0
test "$(grep -c 'post-card__type">Post-mortem' "$h")" -eq 1
cards "$h" | sed -n 4p | grep -q '/postmortems/ci-pm-in-top8'
cards "$h" | tail -1 | grep -q '/artigos/ci-flood-3'
if grep -q 'ci-pm-latest' "$h"; then echo "FAIL: ci-pm-latest não deveria aparecer na home"; exit 1; fi
if grep -q 'ci-pm-future' "$h"; then echo "FAIL: ci-pm-future não deveria aparecer na home"; exit 1; fi
echo "OK"
