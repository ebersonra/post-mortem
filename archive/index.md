---
layout: page
title: Arquivo
subtitle: Navegue post-mortems por ano e mês de publicação.
permalink: /archive/
---

{% assign posts = site.pages | where: 'type', 'postmortem' | where_exp: 'item', 'item.date != nil' | sort: 'date' | reverse %}
{% if posts.size == 0 %}
  <p class="empty-state">Nenhum post-mortem datado ainda.</p>
{% else %}
  {% assign current_year = '' %}
  {% assign seen_months = '' %}
  {% for post in posts %}
    {% assign y = post.date | date: '%Y' %}
    {% if y != current_year %}
      {% if current_year != '' %}</ul></section>{% endif %}
      {% assign current_year = y %}
      {% assign seen_months = '' %}
      <section class="archive-year-block">
        <h2><a href="{{ '/archive/' | append: y | append: '/' | relative_url }}">{{ y }}</a></h2>
        <ul class="archive-month-list">
    {% endif %}
    {% assign m = post.date | date: '%m' %}
    {% assign month_entry = y | append: '-' | append: m %}
    {% unless seen_months contains month_entry %}
      {% assign seen_months = seen_months | append: month_entry | append: ',' %}
      <li><a href="{{ '/archive/' | append: y | append: '/' | append: m | append: '/' | relative_url }}">{% include date-pt.html date=post.date format='month' %}</a></li>
    {% endunless %}
  {% endfor %}
  </ul></section>
{% endif %}
