#!/usr/bin/env bash
# Regenerate default, PM-0001 and PM-0002 Open Graph images (requires: python3, playwright + chromium).
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/generate-og-image.py \
  --output assets/images/og/default.png \
  --kicker "Edição digital" \
  --headline "Post-mortems blameless — aprendizado em produção"
python3 scripts/generate-og-image.py \
  --output assets/images/og/pm-0001.png \
  --kicker "Post-mortem" \
  --headline "PM-0001 — Bot de WhatsApp não chegava a ready"
python3 scripts/generate-og-image.py \
  --output assets/images/og/pm-0002.png \
  --kicker "Post-mortem" \
  --headline "PM-0002 — Do zero à produção em ~16 h: a landing page ética que uma squad de agentes entregou"
python3 scripts/generate-og-image.py --articles
