# Post-mortems

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

1. Adicione `postmortems/PM-XXXX-slug.md` com front matter (`title`, `pm_id`, `date`, `project`, `project_name`, `summary`, `tags`, `status`). Use `date` no primeiro dia do mês de publicação (ex.: `2026-11-01`); o site exibe **mês/ano** nos cards e metadados, não o dia exato.
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

4. Para arquivo por data, adicione stubs quando o ano ou mês ainda não existir:
   - Ano: `archive/YYYY/index.md` com `layout: archive-year`, `year: YYYY`, `permalink: /archive/YYYY/`
   - Mês: `archive/YYYY/MM/index.md` com `layout: archive-month`, `year`, `month`, `month_label` (nome em português), `permalink: /archive/YYYY/MM/`

   O índice em `/archive/` lista anos e meses automaticamente a partir dos post-mortems datados; as páginas de ano/mês filtram por front matter.
