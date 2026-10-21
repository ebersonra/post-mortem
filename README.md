# Tech Blog Bargainly

Post-mortems **blameless** públicos (versões sanitizadas), publicados como site estático via GitHub Pages ("Deploy from a branch": `main`, `/`).

- [PM-0001 — Bot de WhatsApp não chegava a `ready` após mudança na imagem Docker](postmortems/PM-0001-boot-ready-cache-permission.md)

Diagramas em blocos fenced `mermaid` são renderizados no site por `assets/js/mermaid-init.js` (Mermaid 11.17.2 via `_includes/head-custom.html`) e nativamente pelo GitHub.

Formato blameless: o foco está em sistemas e processos, não em pessoas.

## Desenvolvimento local

```bash
bundle config set path vendor/bundle
bundle install
bundle exec jekyll build
```

## Publicar um novo post-mortem

1. Adicione `postmortems/PM-XXXX-slug.md` com front matter (`title`, `pm_id`, `date`, `project`, `project_name`, `summary`, `tags`, `status`). Use `date` no **primeiro dia do mês de publicação à meia-noite em `America/Sao_Paulo`** (ex.: `2026-11-01 00:00:00 -0300`; o site usa `timezone: America/Sao_Paulo` no `_config.yml`) para ordenação correta junto com artigos e metadados (`datePublished`, `article:published_time`) no dia certo em builds locais e no CI; o site exibe **mês/ano** nos cards, não o dia exato.
2. Mantenha o H1 completo no corpo Markdown do post-mortem (o layout não duplica o título).
3. Se o `project` for novo, crie `projects/<slug>.md`:

   ```yaml
   ---
   layout: project
   title: Nome legível
   project: slug-do-projeto
   project_name: Nome legível
   project_description: Descrição curta (opcional).
   permalink: /projects/slug-do-projeto/
   ---
   ```

4. Listagens com loops Liquid + HTML devem ficar em `_layouts/` (ex.: `archive-index`, `projects-index`), não em Markdown indentado — o kramdown trata HTML indentado como bloco de código.

5. Para arquivo por data, adicione stubs quando o ano ou mês ainda não existir:
   - Ano: `archive/YYYY/index.md` com `layout: archive-year`, `year: YYYY`, `permalink: /archive/YYYY/`
   - Mês: `archive/YYYY/MM/index.md` com `layout: archive-month`, `year`, `month`, `month_label` (nome em português), `permalink: /archive/YYYY/MM/`

   O índice em `/archive/` lista anos e meses automaticamente a partir de post-mortems e artigos datados; as páginas de ano/mês filtram por front matter.

## Publicar um artigo

1. Crie `_articles/<slug>.md` (a URL será `/artigos/<slug>.html`). Front matter mínimo:

   ```yaml
   ---
   title: "Título do artigo"
   date: 2026-11-01
   description: "Resumo curto para cards e meta description."
   tags:
     - tag1
     - tag2
   ---
   ```

   Use `date` no primeiro dia do mês, preferencialmente com offset `-0300` (ex.: `2026-11-01 00:00:00 -0300`), como nos post-mortems; o site exibe **mês/ano** nos cards.

2. Mantenha o H1 completo no corpo Markdown (o layout não duplica o título).

3. **Imagem Open Graph (opcional):** gere o card social e referencie no front matter. Sem `image`, o site usa `assets/images/og/default.png` via defaults do `_config.yml`.

   ```bash
   ./scripts/generate-og-images.sh
   ```

   Para um artigo publicado, o script grava `assets/images/og/<slug>.png` (slug = nome do arquivo sem `.md`). Adicione:

   ```yaml
   image:
     path: /assets/images/og/seu-slug.png
     alt: "Descrição acessível da imagem social"
     width: 1200
     height: 630
   ```

4. Rascunhos: use `published: false` para excluir do site (veja `_articles/draft-build-check.md`). O workflow **jekyll-build** copia `tests/fixtures/articles/ci-published-article.md` para `_articles/` só no CI — o site em produção não inclui esse artigo.

   **Atenção:** `published: false` oculta a página no site gerado, mas o arquivo continua **público no repositório Git**. Não faça commit de rascunhos sobre assuntos sensíveis até estarem prontos para publicação.

5. Índice público de artigos: `/artigos/`. A capa e o arquivo listam artigos e post-mortems juntos, ordenados por data. Se o mês ainda não tiver `archive/YYYY/MM/index.md`, o arquivo geral lista o mês como texto (sem link) até você criar a página — evita links 404.

6. Ao publicar em um mês novo, crie os stubs de arquivo como nos post-mortems (passo 5 da seção de post-mortems).
