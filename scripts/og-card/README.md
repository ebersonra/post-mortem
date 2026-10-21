# Open Graph card renderer

Gera PNGs 1200×630 offline a partir de `template.html` via Playwright.

## Fontes

As fontes ficam em `fonts/` (TTF vendored do repositório [google/fonts](https://github.com/google/fonts), licença OFL). **Não há chamada de rede** durante o render.

Se os arquivos em `fonts/` estiverem ausentes, o Chromium usa os fallbacks declarados no CSS (`Georgia`, `Segoe UI`, etc.) — o cartão continua gerando, com tipografia aproximada.

Para restaurar as fontes:

```bash
curl -sL -o fonts/UnifrakturMaguntia-Regular.ttf \
  "https://github.com/google/fonts/raw/main/ofl/unifrakturmaguntia/UnifrakturMaguntia-Regular.ttf"
curl -sL -o fonts/SourceSerif4-Variable.ttf \
  "https://github.com/google/fonts/raw/main/ofl/sourceserif4/SourceSerif4%5Bwght%5D.ttf"
curl -sL -o fonts/SourceSans3-Variable.ttf \
  "https://github.com/google/fonts/raw/main/ofl/sourcesans3/SourceSans3%5Bwght%5D.ttf"
```
