#!/usr/bin/env bash
# Self-tests for scripts/validate-mermaid.sh using fixtures in tests/mermaid.
set -uo pipefail
cd "$(dirname "$0")/.."
v=scripts/validate-mermaid.sh
fail=0
expect() { # expect <exit-code> <pattern> <dirs...>
  local want="$1" pat="$2"; shift 2
  local log rc; log="$("$v" "$@" 2>&1)"; rc=$?
  if [ "$rc" -eq "$want" ] && grep -q -- "$pat" <<<"$log"; then echo "PASS $*: exit $rc"
  else echo "FAIL $*: exit $rc (want $want, pattern '$pat')"; sed 's/^/     /' <<<"$log"; fail=1; fi
}
expect 0 "validados: 1" tests/mermaid/ok
expect 0 "validados: 1" tests/mermaid/indented
expect 0 "validados: 1" tests/mermaid/tilde
expect 1 "sem fechamento" tests/mermaid/unclosed
expect 1 "Nenhum bloco mermaid" tests/mermaid/empty
expect 1 "obrigatório ausente: tests/mermaid/does-not-exist" tests/mermaid/does-not-exist
expect 1 "FAIL" tests/mermaid/broken
expect 1 "cercas de abertura" tests/mermaid/mismatch
expect 0 "validados: 3" tests/mermaid/ok tests/mermaid/indented tests/mermaid/tilde
# Default mode: a missing required folder fails; a missing _posts only warns.
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/postmortems" && cp tests/mermaid/ok/a.md "$tmp/postmortems/"
(cd "$tmp" && "$OLDPWD/$v") >"$tmp/log" 2>&1; rc=$?
if [ "$rc" -eq 1 ] && grep -q "obrigatório ausente: _articles" "$tmp/log"; then echo "PASS default sem _articles: exit 1"
else echo "FAIL default sem _articles: exit $rc"; sed 's/^/     /' "$tmp/log"; fail=1; fi
mkdir -p "$tmp/_articles" && cp tests/mermaid/tilde/a.md "$tmp/_articles/"
(cd "$tmp" && "$OLDPWD/$v") >"$tmp/log" 2>&1; rc=$?
if [ "$rc" -eq 0 ] && grep -q "opcional ausente, ignorado: _posts" "$tmp/log" && grep -q "validados: 2" "$tmp/log"; then echo "PASS default sem _posts: exit 0 com aviso"
else echo "FAIL default sem _posts: exit $rc"; sed 's/^/     /' "$tmp/log"; fail=1; fi
exit $fail
