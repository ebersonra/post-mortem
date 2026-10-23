---
title: "Por que troquei um assistente de IA por uma squad de agentes especializados"
date: 2026-10-23 00:00:00 -0300
description: "Em vez de um assistente genérico, cada agente é um chat com uma skill própria. O que muda quando quem escreve não é quem revisa, e o CI é o juiz final."
tags: [ia, agentes, vibe-coding, devsecops]
image:
  path: /assets/images/og/squad-de-agentes-especializados.png
  alt: "Card do artigo Por que troquei um assistente de IA por uma squad de agentes especializados, no Tech Blog Bargainly"
  width: 1200
  height: 630
---

# Por que troquei um assistente de IA por uma squad de agentes especializados

Montei uma squad de agentes de IA especializados, e o fluxo mudou de patamar. Em vez de um assistente genérico, cada agente é um chat com uma skill própria.

Quem são os agentes, com nome e função, está em [Apresentando o squad](/artigos/apresentando-o-squad.html). Os nomes são personas inspiradas em referências da área, só para dar identidade a cada papel; as pessoas reais não estão envolvidas. Aqui o foco é outro: por que esse formato funciona melhor que um assistente único.

## Como está estruturado

- Cada agente tem um papel definido: Node, Java/Spring, banco de dados, shell, segurança, DevSecOps, front-end e SRE.
- A especialidade vem de uma skill (`SKILL.md`) com convenções, checklist e escopo, não de um prompt solto.
- Cada chat guarda o contexto de uma frente, então o debug de um módulo não polui a conversa sobre outro.
- Os agentes se organizam em grupos por projeto, como uma squad.

## O que isso muda no dia a dia

- **Trabalho em PRs reais:** os agentes fazem commits, abrem e revisam PRs e acompanham o CI até voltar a ficar verde.
- **Delegação entre agentes:** o **Ryan Dahl - Specialist Node** pede ajuda diretamente ao **Vlad Mihalcea - Specialist DB** para contar os formatos de teste, sem que eu precise intermediar.
- **Revisão cruzada:** quem escreve não é quem revisa, o que reduz o viés de "código que o próprio autor aprova".
- **Trabalho assíncrono:** a squad continua entregando enquanto não estou olhando, e o chat funciona como notificação e histórico.
- **Rastreabilidade:** cada decisão fica registrada na conversa, e dá para voltar e entender o porquê.

O fluxo de revisão em detalhe (PR a partir da `main`, três revisores, minha aprovação no fim) está descrito em [Apresentando o squad](/artigos/apresentando-o-squad.html#como-funciona).

## Por que skills + chats funcionam bem juntos

- A skill define o *como*, com regras estáveis e específicas da área.
- O chat carrega o *o quê*, o problema do momento.
- Skills curtas e focadas dão resultado mais previsível que uma instrução gigante e genérica.

## O que aprendi

- Especialização vence generalismo: um agente com escopo estreito erra menos.
- Humano continua decidindo arquitetura e prioridade, e os agentes executam e revisam dentro desses limites.
- CI e testes são o juiz final, e não a opinião do modelo. Foi isso que o artigo [O merge levou o PR, mas não a correção](/artigos/o-merge-levou-o-pr.html) me ensinou na prática.

E você, já trabalha com agentes especializados ou ainda com um assistente único?
