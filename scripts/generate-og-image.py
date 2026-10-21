#!/usr/bin/env python3
"""Render a 1200×630 Open Graph card PNG from scripts/og-card/template.html."""

from __future__ import annotations

import argparse
import hashlib
import html
import subprocess
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = ROOT / "scripts" / "og-card" / "template.html"
FONTS_DIR = TEMPLATE.parent / "fonts"
CHECKSUMS_FILE = FONTS_DIR / "SHA256SUMS"

REQUIRED_FONTS = {
    "UnifrakturMaguntia-Book.ttf": "UnifrakturMaguntia",
    "SourceSerif4-Variable.ttf": "Source Serif 4",
    "SourceSans3-Variable.ttf": "Source Sans 3",
}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def verify_fonts() -> None:
    if not CHECKSUMS_FILE.is_file():
        print(f"Error: missing checksum file {CHECKSUMS_FILE}", file=sys.stderr)
        sys.exit(1)

    expected: dict[str, str] = {}
    for line in CHECKSUMS_FILE.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split(None, 1)
        if len(parts) != 2:
            continue
        expected[parts[1]] = parts[0]

    for filename, family in REQUIRED_FONTS.items():
        path = FONTS_DIR / filename
        if not path.is_file():
            print(f"Error: required font missing: {path}", file=sys.stderr)
            sys.exit(1)
        if filename not in expected:
            print(f"Error: no SHA256 entry for {filename} in {CHECKSUMS_FILE}", file=sys.stderr)
            sys.exit(1)
        actual = sha256_file(path)
        if actual != expected[filename]:
            print(
                f"Error: checksum mismatch for {path}\n"
                f"  expected: {expected[filename]}\n"
                f"  actual:   {actual}",
                file=sys.stderr,
            )
            sys.exit(1)
        file_desc = subprocess.run(
            ["file", "-b", str(path)], check=True, capture_output=True, text=True
        ).stdout.strip()
        if "TrueType" not in file_desc and "OpenType" not in file_desc:
            print(f"Error: {path} is not a valid font (file: {file_desc})", file=sys.stderr)
            sys.exit(1)
        try:
            scan = subprocess.run(
                ["fc-scan", "--format", "%{family}\n", str(path)],
                check=True,
                capture_output=True,
                text=True,
            )
        except FileNotFoundError:
            print("Error: fc-scan is required to validate font family names.", file=sys.stderr)
            sys.exit(1)
        families = scan.stdout.strip()
        if family not in families:
            print(
                f"Error: {path} family mismatch — expected '{family}' in fc-scan output, got: {families!r}",
                file=sys.stderr,
            )
            sys.exit(1)


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


def parse_front_matter(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    block = text[3:end]
    data = yaml.safe_load(block)
    if not isinstance(data, dict):
        return {}
    return data


def generate_article_cards() -> None:
    articles_dir = ROOT / "_articles"
    if not articles_dir.is_dir():
        return
    failed = False
    for path in sorted(articles_dir.glob("*.md")):
        meta = parse_front_matter(path)
        if meta.get("published") is False:
            continue
        slug = path.stem
        raw_title = meta.get("title")
        if raw_title is None or not str(raw_title).strip():
            print(
                f"Error: published article {path.relative_to(ROOT)} requires a non-empty title "
                f"for OG card generation.",
                file=sys.stderr,
            )
            failed = True
            continue
        title = str(raw_title).strip()
        out = ROOT / "assets" / "images" / "og" / f"{slug}.png"
        html_doc = render_html("Artigo", title)
        screenshot(html_doc, out)
        optimize_png(out)
        size_kb = out.stat().st_size / 1024
        print(f"Wrote {out} ({size_kb:.1f} KiB)")
    if failed:
        sys.exit(1)


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate OG social card PNG (1200×630).")
    parser.add_argument("--output", type=Path, help="Output PNG path (e.g. assets/images/og/default.png)")
    parser.add_argument("--kicker", help="Upper kicker label")
    parser.add_argument("--headline", help="Headline text")
    parser.add_argument(
        "--articles",
        action="store_true",
        help="Generate OG cards for each published article in _articles/ (assets/images/og/<slug>.png)",
    )
    args = parser.parse_args()
    verify_fonts()
    if args.articles:
        generate_article_cards()
        return 0
    if not args.output or not args.kicker or not args.headline:
        parser.error("--output, --kicker, and --headline are required unless --articles is set")
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
