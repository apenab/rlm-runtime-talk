# Project: RLM Runtime Talk

Presentacion sobre Recursive Language Models (RLM) — del paper de MIT a implementacion practica con pyrlm-runtime.

## Stack

- **Marp** para generar slides desde Markdown (`rlm-presentation.md`)
- Theme: `uncover` con `class: invert`
- Build: `make preview` (live), `make build` (HTML + PDF), `make html`, `make pdf`

## Preferencias de estilo en slides

- **Usar Boxes (divs HTML) en lugar de listas markdown (ul/ol).** El usuario prefiere cajas visuales con bordes, colores de fondo y bordes redondeados en vez de bullet points o listas numeradas.
- Patron tipico de box:
  ```html
  <div style="display:flex; gap:12px; margin-top:12px;">
    <div
      style="flex:1; background:rgba(96,165,250,0.1); border:1px solid #60a5fa; border-radius:10px; padding:12px;"
    >
      <div style="font-size:1.1em;">Titulo</div>
      <div style="color:#94a3b8; font-size:0.85em;">Descripcion</div>
    </div>
  </div>
  ```
- Colores del theme: azul principal `#60a5fa`, secundario `#93c5fd`, texto muted `#94a3b8`, rojo para negativo `#ef4444`, amarillo para warning `#eab308`, verde para positivo `#22c55e`
- Las notas del presentador van en comentarios HTML `<!-- NOTAS — Titulo -->` debajo de cada slide
- Separador de slides: `---`
- Las notas del orador deben ser detalladas y sustanciales (explicaciones, datos, transiciones, lo que decir en voz alta). Las slides deben ser ligeras visualmente, con la profundidad en las notas
- Para tablas comparativas de seguridad/features, usar `<span>` con colores inline para resaltar estados (rojo=vulnerable, verde=protegido)
- Las slides de `columns` usan `<div class="columns">` (definido en el CSS global)

## Idioma

- Las slides estan en ingles
- Las notas del presentador y TODOs estan en castellano

## Archivos principales

- `rlm-presentation.md` — la presentacion completa
- `TODO.md` — notas y pendientes del autor
- `Makefile` — comandos de build
- `images/` — recursos visuales

## Real project

Este es el main-project de la charla, el código de ejemplo y los benchmarks se encuentran en el repositorio de pyrlm-runtime: https://github.com/apenab/pyrlm-runtime

## Inspiration and references

- Paper original de RLM: https://arxiv.org/pdf/2512.24601
- Blog post: https://alexzhang13.github.io/blog/2025/rlm/
