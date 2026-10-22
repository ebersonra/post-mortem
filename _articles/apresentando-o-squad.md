---
title: "Apresentando o squad: quem são os agentes de IA que constroem comigo"
date: 2026-10-21 00:00:00 -0300
description: "Os projetos deste blog são construídos por um squad de agentes de IA, cada um batizado com uma referência na sua área. Eu decido e aprovo; eles propõem, revisam e corrigem."
tags: [ia, squad, workflow, building-in-public]
image:
  path: /assets/images/og/apresentando-o-squad.png
  alt: "Card do artigo Apresentando o squad, no Tech Blog Bargainly"
  width: 1200
  height: 630
---

# Apresentando o squad: quem são os agentes de IA que constroem comigo

Este blog fala de projetos de tecnologia que eu construo com um squad de agentes de IA. É "vibe coding", mas com regras. Cada agente tem uma função e um nome emprestado de uma referência na sua área. O nome é uma homenagem e um lembrete do padrão que eu espero, não uma afirmação de que a pessoa real está envolvida.

Aqui conto quem são e como trabalhamos.

## Como funciona

A regra principal é simples: **eu decido produto e design, e aprovo tudo**. Os agentes propõem, implementam, revisam e corrigem, mas nada vai para o ar sem o meu ok.

- Cada mudança é um PR novo, criado a partir da `main`.
- Cada PR passa por três revisores: **Uncle Bob - Specialist Code Reviewer**, **Linus Torvalds - Specialist Security** e **Uncle Bob - Tech Architect**.
- Mudanças de design e UX vão para **Jordan Walke - Specialist React**.
- Nada é publicado sem a minha aprovação.

```mermaid
flowchart LR
  E[Eberson decide] --> PR[PR novo a partir da main]
  PR --> CR[Code Reviewer]
  PR --> SEC[Security]
  PR --> ARQ[Tech Architect]
  CR --> FIX[Correções no PR]
  SEC --> FIX
  ARQ --> FIX
  FIX --> OK{Eberson aprova?}
  OK -- não --> FIX
  OK -- sim --> MAIN[Merge na main]
```

Esse fluxo não nasceu pronto. Ele foi sendo ajustado com o que deu errado, e os casos já publicados aqui mostram isso: o [PM-0001](/postmortems/PM-0001-boot-ready-cache-permission.html), sobre o bot que não chegava a `ready`, e o artigo [O merge levou o PR, mas não a correção](/artigos/o-merge-levou-o-pr.html), que me fez definir "pronto" como "o SHA está na `main`".

## O squad

<div class="squad-member" markdown="1">
<img class="squad-avatar" src="/assets/images/squad/avatars/uncle-bob-tech-architect.jpg" width="96" height="96" alt="Uncle Bob - Tech Architect" loading="lazy" decoding="async">
<div class="squad-member__body" markdown="1">

### Uncle Bob - Tech Architect

Não escreve código de produção. Questiona decisões, compara pelo menos duas alternativas e recomenda a mais simples. Planeja migrações em passos pequenos, sempre com rollback, e registra as decisões em RFCs e ADRs.

</div>
</div>

<div class="squad-member" markdown="1">
<img class="squad-avatar" src="/assets/images/squad/avatars/jordan-walke-react.jpg" width="96" height="96" alt="Jordan Walke - Specialist React" loading="lazy" decoding="async">
<div class="squad-member__body" markdown="1">

### Jordan Walke - Specialist React

Cuida da landing page, do app em React Native/Expo e do design system compartilhado. Trabalha com um PR por mudança e um commit por apontamento de review. Só diz que terminou quando a correção está na `main`.

</div>
</div>

<div class="squad-member" markdown="1">
<img class="squad-avatar" src="/assets/images/squad/avatars/uncle-bob-code-reviewer.jpg" width="96" height="96" alt="Uncle Bob - Specialist Code Reviewer" loading="lazy" decoding="async">
<div class="squad-member__body" markdown="1">

### Uncle Bob - Specialist Code Reviewer

Lê só o diff e roda os testes. Procura bugs silenciosos, testes que não testam nada e vazamento de dados sensíveis. Cada apontamento vem com severidade, arquivo/linha e sugestão de correção. Confere de novo antes de fechar e não confia em CI verde sem rodar ele mesmo.

</div>
</div>

<div class="squad-member" markdown="1">
<img class="squad-avatar" src="/assets/images/squad/avatars/linus-torvalds-security.jpg" width="96" height="96" alt="Linus Torvalds - Specialist Security" loading="lazy" decoding="async">
<div class="squad-member__body" markdown="1">

### Linus Torvalds - Specialist Security

Procura segredos commitados, dados pessoais em logs, políticas de banco abertas demais e permissões checadas só no front-end. Só reporta o que confirmou, sempre com nível de risco. Nunca roda exploit em produção. Correções graves precisam do meu ok, e segredo vazado é rotacionado, não só apagado.

</div>
</div>

<div class="squad-member" markdown="1">
<img class="squad-avatar" src="/assets/images/squad/avatars/james-gosling-java.jpg" width="96" height="96" alt="James Gosling - Java Champion" loading="lazy" decoding="async">
<div class="squad-member__body" markdown="1">

### James Gosling - Java Champion

Backend sênior em Java e Spring Boot. Corrige os apontamentos dos revisores em ordem de severidade, escreve testes e revalida.

</div>
</div>

<div class="squad-member" markdown="1">
<img class="squad-avatar" src="/assets/images/squad/avatars/ryan-dahl-node.jpg" width="96" height="96" alt="Ryan Dahl - Specialist Node" loading="lazy" decoding="async">
<div class="squad-member__body" markdown="1">

### Ryan Dahl - Specialist Node

Cuida do que roda em Node.js.

</div>
</div>

<div class="squad-member" markdown="1">
<img class="squad-avatar" src="/assets/images/squad/avatars/vlad-mihalcea-db.jpg" width="96" height="96" alt="Vlad Mihalcea - Specialist DB" loading="lazy" decoding="async">
<div class="squad-member__body" markdown="1">

### Vlad Mihalcea - Specialist DB

Bancos de dados, principalmente Postgres.

</div>
</div>

<div class="squad-member" markdown="1">
<img class="squad-avatar" src="/assets/images/squad/avatars/shannon-lietz-devsecops.jpg" width="96" height="96" alt="Shannon Lietz - DevSecOps" loading="lazy" decoding="async">
<div class="squad-member__body" markdown="1">

### Shannon Lietz - DevSecOps

CI/CD com GitHub Actions para mobile, web, Node e Java.

</div>
</div>

<div class="squad-member" markdown="1">
<img class="squad-avatar" src="/assets/images/squad/avatars/linus-torvalds-shell.jpg" width="96" height="96" alt="Linus Torvalds - Specialist Shell" loading="lazy" decoding="async">
<div class="squad-member__body" markdown="1">

### Linus Torvalds - Specialist Shell

Scripts de shell e Linux.

</div>
</div>

<div class="squad-member" markdown="1">
<img class="squad-avatar" src="/assets/images/squad/avatars/oracle-founders.jpg" width="96" height="96" alt="Larry Ellison &amp; Bob Miner &amp; Ed Oates - Oracle" loading="lazy" decoding="async">
<div class="squad-member__body" markdown="1">

### Larry Ellison & Bob Miner & Ed Oates - Oracle

Cuida da saúde, dos logs e dos reinícios do bot numa VM na nuvem.

</div>
</div>

<div class="squad-member" markdown="1">
<img class="squad-avatar" src="/assets/images/squad/avatars/larry-page-sergey-brin-ga4-seo.jpg" width="96" height="96" alt="Larry Page &amp; Sergey Brin - Specialist GA4 &amp; SEO" loading="lazy" decoding="async">
<div class="squad-member__body" markdown="1">

### Larry Page & Sergey Brin - Specialist GA4 & SEO

Observabilidade e SRE, mais analytics de produto e SEO.

</div>
</div>

### SREs por projeto

Alguns projetos têm um agente de SRE dedicado, cobrindo a API de finanças, o bot de WhatsApp e o Design System. Eles acompanham a saúde de cada projeto de perto.

<div class="squad-member" markdown="1">
<img class="squad-avatar" src="/assets/images/squad/avatars/tech-social-writer.jpg" width="96" height="96" alt="Tech Social Writer" loading="lazy" decoding="async">
<div class="squad-member__body" markdown="1">

### Tech Social Writer

Transforma os posts do blog em posts para LinkedIn, X e Instagram. O blog vem primeiro, e ele prepara e agenda os posts, sempre com a minha aprovação.

</div>
</div>

## Por que contar isso

Os projetos, como o Bargainly e um app de finanças para casais, são construídos assim. Achei justo mostrar quem está por trás de cada PR antes de contar as próximas histórias. Nos próximos posts, a ideia é mostrar cada agente trabalhando em casos reais, com os acertos e os erros.
