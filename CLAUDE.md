# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Project: RLM Runtime Talk

Presentacion sobre Recursive Language Models (RLM) — del paper de MIT a implementacion practica con pyrlm-runtime.

## Stack

- **Marp** para generar slides desde Markdown (`rlm-presentation.md`)
- Theme: `uncover` con `class: invert`
- Build: `make preview` (live), `make build` (HTML + PDF), `make html`, `make pdf`, `make watch` (watch mode)
- Install: `npm install` (local) or `make install` (global)
- **Important:** The `--html` flag is required for inline HTML (divs, spans) to render. The `npm run` scripts include it; if running `marp` directly, add `--html`.

## Slide style preferences

- **Use HTML boxes (divs) instead of markdown lists (ul/ol).** Prefer visual cards with borders, colored backgrounds and rounded corners over bullet points.
- Speaker notes go in HTML comments `<!-- NOTES — Slide title -->` below each slide
- Slide separator: `---`
- Speaker notes should be detailed and substantial (explanations, data, transitions, what to say out loud). Slides should be visually light — depth goes in the notes.
- For security/feature comparison tables, use inline `<span>` with colors to highlight states (red=vulnerable, green=protected)
- Two-column slides use `<div class="columns">` (defined in the global CSS)

---

## Marp Visual Patterns (generic — reusable across projects)

### Base color palette (theme `uncover` + `class: invert`)

```
Primary blue:    #60a5fa      rgba(96,165,250,0.1)   — subtle blue background
Secondary blue:  #93c5fd
Muted text:      #94a3b8
Red (negative):  #ef4444      rgba(239,68,68,0.1)
Yellow (warning):#eab308      rgba(234,179,8,0.12)
Green (positive):#22c55e      rgba(34,197,94,0.12)
Dark background: #0f172a      (code blocks, terminals)
Subtle border:   #334155
```

---

### 1. Card / Box

```html
<div style="display:flex; gap:12px; margin-top:12px;">
  <div style="flex:1; background:rgba(96,165,250,0.1); border:1px solid #60a5fa; border-radius:10px; padding:12px;">
    <div style="font-size:1.1em;">Title</div>
    <div style="color:#94a3b8; font-size:0.85em;">Description</div>
  </div>
</div>
```

Color variants: swap `rgba(...)` and `border` color to match the state (red/yellow/green).

---

### 2. Progressive reveal (animation without JS)

Duplicate the slide and use `visibility:hidden` on elements not yet shown. Each copy reveals one more:

```html
<!-- Slide N: only card 1 visible -->
<div style="flex:1; ...">Card 1</div>
<div style="flex:1; ... visibility:hidden;">Card 2</div>

---

<!-- Slide N+1: cards 1 and 2 visible -->
<div style="flex:1; ...">Card 1</div>
<div style="flex:1; ...">Card 2</div>
```

Rule: use `visibility:hidden` (not `display:none`) to keep the layout stable across slides.

---

### 3. Callout / Info box with side accent

```html
<div style="background:rgba(96,165,250,0.08); border-left:3px solid #60a5fa; border-radius:0 6px 6px 0; padding:7px 12px; font-size:0.82em; color:#e2e8f0; margin-top:10px;">
  Callout text with <strong>emphasis</strong> if needed.
</div>
```

Change `border-left` color per level: blue=info, yellow=warning, red=error, green=success.

---

### 4. Status stack (good → bad progression)

```html
<div style="display:flex; flex-direction:column; gap:10px;">
  <div style="background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:10px; padding:11px; display:flex; align-items:center; gap:10px;">
    <div style="font-size:1.4em;">✅</div>
    <div>
      <div style="font-size:0.95em; font-weight:600; color:#86efac;">Good state</div>
      <div style="font-size:0.8em; color:#94a3b8;">Description</div>
    </div>
  </div>
  <div style="text-align:center; color:#475569; font-size:0.85em;">↓ same model, more context</div>
  <div style="background:rgba(239,68,68,0.15); border:1px solid #ef4444; border-radius:10px; padding:11px; display:flex; align-items:center; gap:10px;">
    <div style="font-size:1.4em;">💥</div>
    <div>
      <div style="font-size:0.95em; font-weight:600; color:#fca5a5;">Bad state</div>
      <div style="font-size:0.8em; color:#94a3b8;">Description</div>
    </div>
  </div>
</div>
```

---

### 5. Impact slide (large text with glow)

No `# heading` — everything directly in divs:

```html
<div style="font-size: 0.85em; color: #93c5fd; margin-bottom: 1rem;">💡 Subtitle or context</div>

<div style="font-size: 2.4em; font-weight: 700; color: #60a5fa; text-shadow: 0 0 20px rgba(96,165,250,0.4);">
  The key insight the audience should remember.
</div>
```

---

### 6. SVG — Bar chart

```html
<svg viewBox="0 0 700 275" xmlns="http://www.w3.org/2000/svg" style="width:100%; max-height:260px;">
  <!-- X axis -->
  <line x1="65" y1="250" x2="685" y2="250" stroke="#334155" stroke-width="1.5"/>
  <!-- Reference line -->
  <line x1="65" y1="191" x2="685" y2="191" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <!-- Bar -->
  <rect x="96" y="104" width="44" height="146" fill="#60a5fa" rx="3"/>
  <text x="118" y="98" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">62</text>
  <!-- X label -->
  <text x="118" y="268" text-anchor="middle" fill="#94a3b8" font-size="11">Label</text>
  <!-- Legend -->
  <rect x="85" y="10" width="10" height="10" fill="#60a5fa" rx="2"/>
  <text x="100" y="19" fill="#94a3b8" font-size="11">Series A</text>
</svg>
```

---

### 7. SVG — Line chart with zones

```html
<svg viewBox="0 0 680 265" xmlns="http://www.w3.org/2000/svg" style="width:100%; max-height:240px;">
  <!-- Danger zone background -->
  <rect x="496" y="20" width="184" height="200" fill="rgba(239,68,68,0.07)"/>
  <!-- Limit line -->
  <line x1="496" y1="20" x2="496" y2="220" stroke="#ef4444" stroke-width="1.5" stroke-dasharray="5,4" opacity="0.7"/>
  <text x="500" y="16" fill="#ef4444" font-size="10">Limit</text>
  <!-- Degrading series -->
  <polyline points="70,100 239,110 412,132 496,164 660,212"
            fill="none" stroke="#ef4444" stroke-width="2.5" stroke-linejoin="round"/>
  <!-- Stable series -->
  <polyline points="70,104 239,106 412,108 496,110 660,110"
            fill="none" stroke="#60a5fa" stroke-width="2.5" stroke-linejoin="round"/>
  <!-- Axes -->
  <line x1="65" y1="220" x2="665" y2="220" stroke="#334155" stroke-width="1.5"/>
  <line x1="65" y1="20"  x2="65"  y2="220" stroke="#334155" stroke-width="1.5"/>
  <!-- Inline legend -->
  <rect x="80" y="8" width="10" height="10" fill="#60a5fa" rx="2"/>
  <text x="95" y="17" fill="#94a3b8" font-size="11">New system</text>
  <rect x="200" y="8" width="10" height="10" fill="#ef4444" rx="2"/>
  <text x="215" y="17" fill="#94a3b8" font-size="11">Current system</text>
</svg>
```

---

### 8. Architecture diagram (HTML table)

For connected component flows. Use `border-collapse:separate` and `border-spacing` for spacing control:

```html
<table style="width:100%; border-collapse:separate; border-spacing:4px; background:rgba(30,58,95,0.4); border:2px solid #3b82f6; border-radius:10px; padding:8px;">
  <tr>
    <td colspan="3" style="border:none; text-align:center; padding:6px;">
      <div style="background:rgba(234,179,8,0.15); border:2px solid #eab308; border-radius:8px; padding:8px; font-weight:700;">📋 Input</div>
      <div style="text-align:center; color:#475569; font-size:1.2em;">↓</div>
    </td>
  </tr>
  <tr style="vertical-align:top;">
    <td style="border:none; padding:6px; width:33%;">
      <div style="background:rgba(96,165,250,0.15); border:2px solid #60a5fa; border-radius:8px; padding:10px; text-align:center;">🔀 Component A</div>
    </td>
    <td style="border:none; padding:6px; width:33%;">
      <div style="background:rgba(34,197,94,0.15); border:2px solid #22c55e; border-radius:8px; padding:10px; text-align:center;">⚙️ Component B</div>
    </td>
    <td style="border:none; padding:6px; width:33%;">
      <div style="background:rgba(239,68,68,0.15); border:2px solid #ef4444; border-radius:8px; padding:10px; text-align:center;">📤 Output</div>
    </td>
  </tr>
</table>
```

---

### 9. UI simulation (chat / terminal)

**Chat:**
```html
<div style="background:#0f172a; border:1px solid #334155; border-radius:12px; overflow:hidden; margin-top:16px;">
  <!-- macOS-style title bar -->
  <div style="background:#1e293b; border-bottom:1px solid #334155; padding:8px 14px; display:flex; align-items:center; gap:8px;">
    <span style="color:#ef4444; font-size:0.7em;">●</span>
    <span style="color:#eab308; font-size:0.7em;">●</span>
    <span style="color:#22c55e; font-size:0.7em;">●</span>
    <span style="color:#94a3b8; font-size:0.62em; margin-left:8px;">Window title</span>
  </div>
  <div style="padding:16px;">
    <!-- User bubble (left) -->
    <div style="margin-bottom:12px;">
      <div style="font-size:0.6em; color:#60a5fa; margin-bottom:4px; font-weight:bold;">User</div>
      <div style="background:rgba(96,165,250,0.12); border:1px solid #60a5fa; border-radius:2px 12px 12px 12px; padding:10px 14px; max-width:75%; font-size:0.82em;">User message</div>
    </div>
    <!-- Response bubble (right) -->
    <div style="display:flex; flex-direction:column; align-items:flex-end;">
      <div style="font-size:0.6em; color:#22c55e; margin-bottom:4px; font-weight:bold;">System</div>
      <div style="background:rgba(34,197,94,0.08); border:1px solid #22c55e; border-radius:12px 2px 12px 12px; padding:10px 14px; max-width:75%; font-size:0.82em;">System response</div>
    </div>
  </div>
</div>
```

**Progress bar** (inside chat):
```html
<div style="display:flex; height:4px; border-radius:2px; overflow:hidden; margin:8px 0;">
  <div style="width:30%; background:#60a5fa;"></div>
  <div style="width:70%; background:#1e293b;"></div>
</div>
<div style="font-size:0.55em; color:#475569; text-align:center;">processing <span style="color:#60a5fa;">15,000</span> / 50,000...</div>
```

**Terminal / REPL:**
```html
<div style="background:#0f172a; border:1px solid #334155; border-radius:8px; padding:12px; font-family:'Consolas',monospace; font-size:0.8em;">
  <div style="color:#475569; margin-bottom:6px;">In [1]:</div>
  <div style="color:#a5f3fc;">result = process(data)</div>
  <div style="color:#475569; margin-top:8px; margin-bottom:4px;">Out[1]:</div>
  <div style="background:rgba(148,163,184,0.1); border:1px solid #475569; border-radius:4px; padding:6px; color:#e2e8f0;">"[ output here ]"</div>
</div>
```

---

### 10. Badge / Pill

```html
<div style="display:flex; gap:8px; margin-top:10px; flex-wrap:wrap;">
  <div style="background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:6px; padding:5px 10px; font-size:0.78em; color:#93c5fd;">
    <strong>LABEL</strong> — short description
  </div>
  <div style="background:rgba(34,197,94,0.08); border:1px solid rgba(34,197,94,0.3); border-radius:6px; padding:5px 10px; font-size:0.78em; color:#86efac;">
    <strong>OTHER</strong> — description
  </div>
</div>
```

---

### 11. Polaroid image gallery

```html
<div style="display:flex; flex-wrap:wrap; align-items:center; justify-content:center; gap:16px; padding:6px;">
  <div style="transform:rotate(-4deg); box-shadow:3px 4px 12px rgba(0,0,0,0.5); background:#f5f0e8; padding:8px 8px 32px 8px;">
    <img src="images/photo.png" style="display:block; max-height:250px; max-width:300px; object-fit:cover;">
  </div>
  <div style="transform:rotate(3deg); box-shadow:4px 5px 14px rgba(0,0,0,0.5); background:#fefefe; padding:8px 8px 32px 8px;">
    <img src="images/photo2.png" style="display:block; max-height:250px; max-width:300px; object-fit:cover;">
  </div>
</div>
```

---

### 12. QR code layout (closing slide)

```html
<div style="display:flex; align-items:center; justify-content:space-between; height:100%; padding:0 20px;">
  <div style="flex:1; padding-right:40px;">
    <!-- left content: links, bullets, etc. -->
  </div>
  <div style="display:flex; flex-direction:column; align-items:center; gap:12px;">
    <img src="images/qr.png" style="width:260px; height:260px; border-radius:12px; border:3px solid #60a5fa; padding:6px; background:white;" />
    <div style="font-size:0.75em; color:#94a3b8;">github.com/user/repo</div>
  </div>
</div>
```

---

### 13. Code block with syntax highlighting

Inside a flex column container (`align-items:center`), always add `align-self:stretch` and `text-align:left` to the code block. The `uncover` theme applies `text-align:center` globally — without `text-align:left` the indentation renders centered. Use one `<div>` per line and `padding-left` for indentation (not `&nbsp;` or `<br>`).

```html
<div style="background:#0f172a; border:1px solid #334155; border-radius:6px; padding:8px 12px; font-family:monospace; font-size:0.75em; line-height:1.8; align-self:stretch; box-sizing:border-box; text-align:left;">
  <div><span style="color:#60a5fa;">for</span> chunk <span style="color:#60a5fa;">in</span> <span style="color:#fbbf24;">P</span>.chunks():</div>
  <div style="padding-left:1.5em;">r = <span style="color:#c084fc;">llm_query</span>(chunk)</div>
  <div style="padding-left:1.5em;">results.append(r)</div>
</div>
```

Token colors: keywords `#60a5fa`, variables `#fbbf24`, functions `#c084fc`, strings `#86efac`, comments `#475569`.

---

### General rules

- Always use the `--html` flag in Marp to render inline HTML
- Use `visibility:hidden` (not `display:none`) in progressive reveal to keep the layout stable
- Impact slides: no `#` heading — everything in divs with large font-size
- `font-size` in `em` is relative to `section { font-size: 24px }` in the theme
- Speaker notes: `<!-- NOTES — Slide title -->`

## Language

- Slides are in English
- Speaker notes and TODOs are in Spanish

## Archivos principales

- `rlm-presentation.md` — la presentacion completa
- `TODO.md` — notas y pendientes del autor
- `Makefile` — comandos de build
- `images/` — recursos visuales

## Real project

Este es el main-project de la charla, el código de ejemplo y los benchmarks se encuentran en el repositorio de pyrlm-runtime: https://github.com/apenab/pyrlm-runtime

## Paper source of truth

**IMPORTANTE:** El paper original del MIT está disponible en `paper-mit.pdf` en la raíz del repositorio. Antes de inferir cualquier concepto técnico sobre RLM (arquitectura, algoritmos, propiedades, terminología, flujos de datos), **leer primero el paper**. No asumir ni inventar — si hay duda, consultar `paper-mit.pdf`.

Conceptos clave del paper (Figure 2, Algorithm 1):
- El **context** se carga como variable `P` en el Environment E (REPL) — nunca se envía directamente al LLM
- El **query** llega al LLM como metadata del REPL (longitud, prefijo, estructura)
- El LLM genera código → se ejecuta en el REPL → stdout vuelve al LLM (loop iterativo)
- `llm_query(sub_context)` spawns child RLMs (recursión simbólica)
- El loop termina cuando el LLM emite `FINAL:` o `FINAL_VAR:`

## Inspiration and references

- Paper original de RLM (local): `paper-mit.pdf`
- Paper original de RLM (arxiv): https://arxiv.org/pdf/2512.24601
- Blog post: https://alexzhang13.github.io/blog/2025/rlm/
