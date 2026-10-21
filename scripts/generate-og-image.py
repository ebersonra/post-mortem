#!/usr/bin/env python3
"""Render a 1200×630 Open Graph card PNG from scripts/og-card/template.html."""

from __future__ import annotations

import argparse
import html
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = ROOT / "scripts" / "og-card" / "template.html"


def load_template() -> str:
    return TEMPLATE.read_text(encoding="utf-8")


def render_html(kicker: str, headline: str) -> str:
    content = load_template()
    content = content.replace("__KICKER__", html.escape(kicker))
    content = content.replace("__HEADLINE__", html.escape(headline))
    return content


def optimize_png(path: Path) -> None:
    try:
        subprocess.run(
            ["pngquant", "--force", "--skip-if-larger", "--quality", "65-85", "-o", str(path), str(path)],
            check=True,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError:
        print(
            "Warning: pngquant not found; PNG was written without lossy optimization.",
            file=sys.stderr,
        )
    except subprocess.CalledProcessError as err:
        detail = (err.stderr or err.stdout or "").strip()
        print(
            "Warning: pngquant failed; PNG was written without lossy optimization."
            + (f" ({detail})" if detail else ""),
            file=sys.stderr,
        )


def screenshot(html: str, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    tmp_path = TEMPLATE.parent / ".render-temp.html"
    tmp_path.write_text(html, encoding="utf-8")
    try:
        from playwright.sync_api import sync_playwright

        with sync_playwright() as p:
            browser = p.chromium.launch()
            page = browser.new_page(viewport={"width": 1200, "height": 630}, device_scale_factor=1)
            page.goto(tmp_path.as_uri(), wait_until="load")
            page.wait_for_timeout(800)
            page.screenshot(path=str(output), type="png", clip={"x": 0, "y": 0, "width": 1200, "height": 630})
            browser.close()
    finally:
        tmp_path.unlink(missing_ok=True)


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate OG social card PNG (1200×630).")
    parser.add_argument("--output", required=True, type=Path, help="Output PNG path (e.g. assets/images/og/default.png)")
    parser.add_argument("--kicker", required=True, help="Upper kicker label")
    parser.add_argument("--headline", required=True, help="Headline text")
    args = parser.parse_args()
    out = args.output if args.output.is_absolute() else ROOT / args.output
    html_doc = render_html(args.kicker.strip(), args.headline.strip())
    screenshot(html_doc, out)
    optimize_png(out)
    size_kb = out.stat().st_size / 1024
    print(f"Wrote {out} ({size_kb:.1f} KiB)")
    if size_kb > 300:
        print("Warning: image exceeds ~300 KiB target; consider shorter headline or pngquant.", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
