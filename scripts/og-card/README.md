# Open Graph card renderer

Gera PNGs 1200×630 offline a partir de `template.html` via Playwright.

## Fontes

Arquivos TTF vendored em `fonts/` (repositório [google/fonts](https://github.com/google/fonts), licença OFL). **Sem rede** no render.

Integridade: `fonts/SHA256SUMS` — verificado por `scripts/generate-og-image.py` antes de cada geração (checksum, `file`, `fc-scan`). Falha ruidosamente se algo estiver ausente ou inválido.

Dependências Python (OG): `pip install -r scripts/requirements-og.txt`. O modo `--articles` lê front matter com `yaml.safe_load`, ignora `published: false` (e outros valores YAML falsos), e encerra com erro se um artigo publicado não tiver `title`.

Para baixar novamente (use `curl -fsSL`):

```bash
cd scripts/og-card/fonts
curl -fsSL -o UnifrakturMaguntia-Book.ttf \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/unifrakturmaguntia/UnifrakturMaguntia-Book.ttf"
curl -fsSL -o SourceSerif4-Variable.ttf \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/sourceserif4/SourceSerif4%5Bopsz,wght%5D.ttf"
curl -fsSL -o SourceSans3-Variable.ttf \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/sourcesans3/SourceSans3%5Bwght%5D.ttf"
sha256sum UnifrakturMaguntia-Book.ttf SourceSerif4-Variable.ttf SourceSans3-Variable.ttf > SHA256SUMS
```
