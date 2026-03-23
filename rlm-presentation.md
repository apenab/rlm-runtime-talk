---
marp: true
theme: uncover
class: invert
paginate: true
style: |
  section {
    font-size: 24px;
    justify-content: flex-start;
  }
  h1 {
    color: #60a5fa;
    font-size: 1.3em;
    margin-bottom: 0.25em;
  }
  h2 {
    color: #93c5fd;
  }
  ul, ol {
    margin-left: 0;
    padding-left: 1.2em;
  }
  li {
    text-align: left;
    margin-bottom: 0.3em;
    padding-left: 0.3em;
  }
  /* Cool custom bullets */
  ul {
    list-style: none;
    padding-left: 0;
  }
  ul > li {
    position: relative;
    padding-left: 1.4em;
  }
  ul > li::before {
    content: "▸";
    position: absolute;
    left: 0;
    color: #60a5fa;
    font-weight: 700;
    font-size: 1.1em;
  }
  /* Nested bullets get a different marker */
  ul > li > ul > li::before {
    content: "›";
    color: #818cf8;
  }
  /* Numbered lists: glowing accent */
  ol {
    list-style: none;
    padding-left: 0;
    counter-reset: ol-counter;
  }
  ol > li {
    position: relative;
    padding-left: 2em;
    counter-increment: ol-counter;
  }
  ol > li::before {
    content: counter(ol-counter);
    position: absolute;
    left: 0;
    background: rgba(96,165,250,0.2);
    color: #60a5fa;
    font-weight: 700;
    width: 1.4em;
    height: 1.4em;
    line-height: 1.4em;
    border-radius: 50%;
    font-size: 0.85em;
  }
  code {
    background: rgba(255,255,255,0.1);
    padding: 2px 6px;
    border-radius: 4px;
    font-size: 0.85em;
  }
  pre {
    background: #0f172a;
    color: #e2e8f0;
    padding: 16px;
    border-radius: 8px;
    font-size: 0.75em;
  }
  pre code {
    background: transparent;
    font-size: inherit;
  }

  table {
    font-size: 0.85em;
  }
  th {
    background: rgba(96,165,250,0.2);
  }
  blockquote {
    border-left-color: #60a5fa;
    color: #cbd5e1;
  }
  a {
    color: #60a5fa;
  }
  strong {
    color: #f1f5f9;
  }
  .columns {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
---

# 🧠 When Context Becomes a Systems Problem: Recursive Language Models

## From MIT Paper to Practical Implementation

**Rethinking how LLMs handle long contexts**

---

# 🤔 The Problem We All Know

Imagine giving GPT-5 an entire 500-page book...

```
User: "What happened in chapter 37?"
GPT-5: "I'm sorry, the context is too long... 🤷"
```

<!--
NOTAS — The Problem We All Know (0/3)

Imagen familiar para todos. Le das a GPT-5 un libro entero y se rinde.
¿Cuáles son las opciones que tenemos hoy?
-->

---

# 🤔 The Problem We All Know

Imagine giving GPT-5 an entire 500-page book...

```
User: "What happened in chapter 37?"
GPT-5: "I'm sorry, the context is too long... 🤷"
```

**Current solutions:**

<div style="display:flex; gap:12px; margin-top:12px;">
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:12px;">
    <div style="font-size:1.3em; margin-bottom:4px;">❌ Truncation</div>
    <div style="color:#94a3b8; font-size:0.85em;">Loses crucial information</div>
  </div>
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:12px; visibility:hidden;">
    <div style="font-size:1.3em; margin-bottom:4px;">❌ RAG</div>
    <div style="color:#94a3b8; font-size:0.85em;">Can't reason over the whole document</div>
  </div>
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:12px; visibility:hidden;">
    <div style="font-size:1.3em; margin-bottom:4px;">❌ Long-context</div>
    <div style="color:#94a3b8; font-size:0.85em;">Performance still degrades with length</div>
  </div>
</div>

<!--
NOTAS — The Problem We All Know (1/3)

Lo más sencillo: si no cabe, se corta. Si la respuesta estaba en lo cortado, mala suerte.
→ ¿Y si en vez de cortar, recuperamos solo lo relevante?
-->

---

# 🤔 The Problem We All Know

Imagine giving GPT-5 an entire 500-page book...

```
User: "What happened in chapter 37?"
GPT-5: "I'm sorry, the context is too long... 🤷"
```

**Current solutions:**

<div style="display:flex; gap:12px; margin-top:12px;">
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:12px;">
    <div style="font-size:1.3em; margin-bottom:4px;">❌ Truncation</div>
    <div style="color:#94a3b8; font-size:0.85em;">Loses crucial information</div>
  </div>
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:12px;">
    <div style="font-size:1.3em; margin-bottom:4px;">❌ RAG</div>
    <div style="color:#94a3b8; font-size:0.85em;">Can't reason over the whole document</div>
  </div>
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:12px; visibility:hidden;">
    <div style="font-size:1.3em; margin-bottom:4px;">❌ Long-context</div>
    <div style="color:#94a3b8; font-size:0.85em;">Performance still degrades with length</div>
  </div>
</div>

<!--
NOTAS — The Problem We All Know (2/3)

RAG recupera fragmentos relevantes. Funciona para preguntas localizadas, pero si la tarea necesita procesar cada línea del documento, te deja a medias.
→ ¿Y si simplemente ampliamos la ventana de contexto?
-->

---

# 🤔 The Problem We All Know

Imagine giving GPT-5 an entire 500-page book...

```
User: "What happened in chapter 37?"
GPT-5: "I'm sorry, the context is too long... 🤷"
```

**Current solutions:**

<div style="display:flex; gap:12px; margin-top:12px;">
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:12px;">
    <div style="font-size:1.3em; margin-bottom:4px;">❌ Truncation</div>
    <div style="color:#94a3b8; font-size:0.85em;">Loses crucial information</div>
  </div>
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:12px;">
    <div style="font-size:1.3em; margin-bottom:4px;">❌ RAG</div>
    <div style="color:#94a3b8; font-size:0.85em;">Can't reason over the whole document</div>
  </div>
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:12px;">
    <div style="font-size:1.3em; margin-bottom:4px;">❌ Long-context</div>
    <div style="color:#94a3b8; font-size:0.85em;">Performance still degrades with length</div>
  </div>
</div>

<!--
NOTAS — The Problem We All Know (3/3)

Ventana más grande, mismo problema: el rendimiento sigue cayendo cuanto más crece el contexto. Y pagas por cada token aunque el modelo no los procese bien.
→ Ese fenómeno de degradación tiene nombre.
-->

---

# 📉 Context Rot is Real

<div class="columns">
<div>

<div style="display:flex; flex-direction:column; gap:10px; margin-top:6px;">
  <div style="background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:10px; padding:11px; display:flex; align-items:center; gap:10px;">
    <div style="font-size:1.4em;">✅</div>
    <div>
      <div style="font-size:0.95em; font-weight:600; color:#86efac;">Short context</div>
      <div style="font-size:0.8em; color:#94a3b8;">High accuracy — model handles it well</div>
    </div>
  </div>
  <div style="text-align:center; color:#475569; font-size:0.85em;">↓ same model, more context</div>
  <div style="background:rgba(234,179,8,0.12); border:1px solid #eab308; border-radius:10px; padding:11px; display:flex; align-items:center; gap:10px;">
    <div style="font-size:1.4em;">⚠️</div>
    <div>
      <div style="font-size:0.95em; font-weight:600; color:#fde68a;">Medium context</div>
      <div style="font-size:0.8em; color:#94a3b8;">Quality starts dropping — still within window</div>
    </div>
  </div>
  <div style="text-align:center; color:#475569; font-size:0.85em;">↓ keep going</div>
  <div style="background:rgba(239,68,68,0.15); border:1px solid #ef4444; border-radius:10px; padding:11px; display:flex; align-items:center; gap:10px;">
    <div style="font-size:1.4em;">💥</div>
    <div>
      <div style="font-size:0.95em; font-weight:600; color:#fca5a5;">Long context</div>
      <div style="font-size:0.8em; color:#94a3b8;">Collapses — <em>before</em> hitting the limit</div>
    </div>
  </div>
</div>

<div style="background:rgba(239,68,68,0.08); border-left:3px solid #ef4444; border-radius:0 6px 6px 0; padding:7px 12px; font-size:0.8em; color:#e2e8f0; margin-top:12px;">
  Not just a window size problem — <strong>attention dilutes with length</strong>
</div>

</div>
<div>

**Real example (Figure 2, MIT paper):**

```
"In chapter 1, Alice and Bob are alive...

[hundreds of pages]

...In chapter 25, Bob died.

[hundreds of pages]

...In chapter 50: who died?"

GPT-5: "Alice" ❌
```

<div style="background:rgba(239,68,68,0.08); border:1px solid #475569; border-radius:8px; padding:8px 12px; font-size:0.82em; color:#94a3b8; margin-top:8px;">The model didn't hit a hard limit — it <strong style="color:#fca5a5;">degraded</strong> as the context grew.</div>

</div>
</div>

<!--
NOTAS — Context Rot is Real

No es que el modelo no pueda con el volumen — es que cuanto más contexto, peor la calidad. GPT-5 en OOLONG: 60% con 8K, 44% con 131K, colapsa al límite. Mismo modelo, peor respuesta.
El ejemplo del libro está en el paper (Figure 2). El modelo no se quedó sin ventana, simplemente degradó.
→ La solución brillante del MIT: ¿y si el contexto nunca entra en la red neuronal?
-->

---

<div style="font-size: 0.85em; color: #93c5fd; margin-bottom: 1rem;">💡 The Brilliant Insight from MIT</div>

<div style="font-size: 2.4em; font-weight: 700; color: #60a5fa; text-shadow: 0 0 20px rgba(96,165,250,0.4);">What if we treat the context as part of the <em>environment</em> instead of loading it all into memory?</div>

<!--
NOTAS — The Brilliant Insight from MIT (0/3)

Nadie carga un archivo de 10GB en memoria. Lo abres, buscas, filtras. ¿Por qué los LLMs no hacen lo mismo?
→ Vamos a ver cómo.
-->

---

# 💡 The Brilliant Insight from MIT

> **What if we treat the context as part of the _environment_ instead of loading it all into memory?**

Like a programmer with a huge file:

<div style="display:flex; gap:12px; margin-top:14px;">
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:14px; text-align:center !important;">
    <div style="font-size:1.6em;">🚫</div>
    <div style="font-size:0.95em; margin-top:4px; color:#fca5a5; font-weight:600;">Don't load everything</div>
    <div style="font-size:0.8em; color:#94a3b8; margin-top:2px;">RAM would explode — so why do we do this with LLMs?</div>
  </div>
  <div style="flex:1; background:rgba(234,179,8,0.12); border:1px solid #eab308; border-radius:10px; padding:14px; text-align:center !important; visibility:hidden;">
    <div style="font-size:1.6em;">🔎</div>
    <div style="font-size:0.95em; margin-top:4px; color:#fde68a; font-weight:600;">Search on demand</div>
    <div style="font-size:0.8em; color:#94a3b8; margin-top:2px;">Open, grep, filter — inspect only what matters</div>
  </div>
  <div style="flex:1; background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:10px; padding:14px; text-align:center !important; visibility:hidden;">
    <div style="font-size:1.6em;">🧬</div>
    <div style="font-size:0.95em; margin-top:4px; color:#86efac; font-weight:600;">Recurse & conquer</div>
    <div style="font-size:0.8em; color:#94a3b8; margin-top:2px;">Split the problem, delegate to sub-calls, merge results</div>
  </div>
</div>

<!--
NOTAS — The Brilliant Insight from MIT (1/3)

Si no metes el contexto en el prompt, la atención no se diluye. El modelo trabaja siempre sobre fragmentos pequeños.
→ Pero entonces, ¿cómo lo inspecciona? Buscando bajo demanda.
-->

---

# 💡 The Brilliant Insight from MIT

> **What if we treat the context as part of the _environment_ instead of loading it all into memory?**

Like a programmer with a huge file:

<div style="display:flex; gap:12px; margin-top:14px;">
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:14px; text-align:center !important;">
    <div style="font-size:1.6em;">🚫</div>
    <div style="font-size:0.95em; margin-top:4px; color:#fca5a5; font-weight:600;">Don't load everything</div>
    <div style="font-size:0.8em; color:#94a3b8; margin-top:2px;">RAM would explode — so why do we do this with LLMs?</div>
  </div>
  <div style="flex:1; background:rgba(234,179,8,0.12); border:1px solid #eab308; border-radius:10px; padding:14px; text-align:center !important;">
    <div style="font-size:1.6em;">🔎</div>
    <div style="font-size:0.95em; margin-top:4px; color:#fde68a; font-weight:600;">Search on demand</div>
    <div style="font-size:0.8em; color:#94a3b8; margin-top:2px;">Open, grep, filter — inspect only what matters</div>
  </div>
  <div style="flex:1; background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:10px; padding:14px; text-align:center !important; visibility:hidden;">
    <div style="font-size:1.6em;">🧬</div>
    <div style="font-size:0.95em; margin-top:4px; color:#86efac; font-weight:600;">Recurse & conquer</div>
    <div style="font-size:0.8em; color:#94a3b8; margin-top:2px;">Split the problem, delegate to sub-calls, merge results</div>
  </div>
</div>

<!--
NOTAS — The Brilliant Insight from MIT (2/3)

Escribe código: peek(), grep(), filtrar. Solo ve lo que necesita, cuando lo necesita.
→ Y si el problema es tan grande que ni grep alcanza: divide, delega, combina.
-->

---

# 💡 The Brilliant Insight from MIT

> **What if we treat the context as part of the _environment_ instead of loading it all into memory?**

Like a programmer with a huge file:

<div style="display:flex; gap:12px; margin-top:14px;">
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:14px; text-align:center !important;">
    <div style="font-size:1.6em;">🚫</div>
    <div style="font-size:0.95em; margin-top:4px; color:#fca5a5; font-weight:600;">Don't load everything</div>
    <div style="font-size:0.8em; color:#94a3b8; margin-top:2px;">RAM would explode — so why do we do this with LLMs?</div>
  </div>
  <div style="flex:1; background:rgba(234,179,8,0.12); border:1px solid #eab308; border-radius:10px; padding:14px; text-align:center !important;">
    <div style="font-size:1.6em;">🔎</div>
    <div style="font-size:0.95em; margin-top:4px; color:#fde68a; font-weight:600;">Search on demand</div>
    <div style="font-size:0.8em; color:#94a3b8; margin-top:2px;">Open, grep, filter — inspect only what matters</div>
  </div>
  <div style="flex:1; background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:10px; padding:14px; text-align:center !important;">
    <div style="font-size:1.6em;">🧬</div>
    <div style="font-size:0.95em; margin-top:4px; color:#86efac; font-weight:600;">Recurse & conquer</div>
    <div style="font-size:0.8em; color:#94a3b8; margin-top:2px;">Split the problem, delegate to sub-calls, merge results</div>
  </div>
</div>

---

# 💡 The Brilliant Insight from MIT

> **What if we treat the context as part of the _environment_ instead of loading it all into memory?**

Like a programmer with a huge file:

<div style="display:flex; gap:12px; margin-top:14px;">
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:14px; text-align:center !important;">
    <div style="font-size:1.6em;">🚫</div>
    <div style="font-size:0.95em; margin-top:4px; color:#fca5a5; font-weight:600;">Don't load everything</div>
    <div style="font-size:0.8em; color:#94a3b8; margin-top:2px;">RAM would explode — so why do we do this with LLMs?</div>
  </div>
  <div style="flex:1; background:rgba(234,179,8,0.12); border:1px solid #eab308; border-radius:10px; padding:14px; text-align:center !important;">
    <div style="font-size:1.6em;">🔎</div>
    <div style="font-size:0.95em; margin-top:4px; color:#fde68a; font-weight:600;">Search on demand</div>
    <div style="font-size:0.8em; color:#94a3b8; margin-top:2px;">Open, grep, filter — inspect only what matters</div>
  </div>
  <div style="flex:1; background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:10px; padding:14px; text-align:center !important;">
    <div style="font-size:1.6em;">🧬</div>
    <div style="font-size:0.95em; margin-top:4px; color:#86efac; font-weight:600;">Recurse & conquer</div>
    <div style="font-size:0.8em; color:#94a3b8; margin-top:2px;">Split the problem, delegate to sub-calls, merge results</div>
  </div>
</div>

<div style="background:linear-gradient(135deg, rgba(96,165,250,0.2), rgba(168,85,247,0.2)); border:2px solid #60a5fa; border-radius:12px; padding:12px; text-align:center !important; margin-top:16px; font-size:1.15em; font-weight:700; color:#e2e8f0;">
  🧠 This is <span style="color:#60a5fa;">RLM</span>: Recursive Language Models
</div>

<!--
NOTAS — The Brilliant Insight from MIT (reveal final)

Tres ideas sencillas. Juntas eliminan el context rot: el modelo siempre trabaja sobre trozos pequeños, sin importar el tamaño total.
→ Ahora vamos con las 3 propiedades formales — y por qué CodeAct o ReAct, que parecen similares, no son RLMs.
-->

---

# 🏗️ The 3 Defining Properties of RLM

From the paper (MIT CSAIL 2025):

<div style="display:flex; flex-direction:column; gap:10px; margin-top:14px;">
  <div style="display:flex; align-items:stretch; gap:12px;">
    <div style="background:rgba(234,179,8,0.15); border:2px solid #eab308; border-radius:12px; padding:14px 16px; flex:1; display:flex; align-items:center; gap:14px;">
      <div style="font-size:2em; min-width:48px; text-align:center !important;">📌</div>
      <div>
        <div style="font-size:1.05em; font-weight:700; color:#fde68a;">1 · Symbolic handle to the prompt</div>
        <div style="font-size:0.85em; color:#94a3b8; margin-top:2px;">Context stored as variable <code style="background:rgba(255,255,255,0.08); color:#fbbf24;">P</code> in memory — never inside the neural network</div>
      </div>
    </div>
  </div>
  <div style="display:flex; align-items:stretch; gap:12px; visibility:hidden;">
    <div style="background:rgba(34,197,94,0.12); border:2px solid #22c55e; border-radius:12px; padding:14px 16px; flex:1; display:flex; align-items:center; gap:14px;">
      <div style="font-size:2em; min-width:48px; text-align:center !important;">⚙️</div>
      <div>
        <div style="font-size:1.05em; font-weight:700; color:#86efac;">2 · Persistent Turing-complete environment</div>
        <div style="font-size:0.85em; color:#94a3b8; margin-top:2px;">Python REPL that persists across iterations — define functions, accumulate state, build logic</div>
      </div>
    </div>
  </div>
  <div style="display:flex; align-items:stretch; gap:12px; visibility:hidden;">
    <div style="background:rgba(96,165,250,0.15); border:2px solid #3b82f6; border-radius:12px; padding:14px 16px; flex:1; display:flex; align-items:center; gap:14px;">
      <div style="font-size:2em; min-width:48px; text-align:center !important;">🔄</div>
      <div>
        <div style="font-size:1.05em; font-weight:700; color:#93c5fd;">3 · Symbolic recursion</div>
        <div style="font-size:0.85em; color:#94a3b8; margin-top:2px;">LLM calls itself via <code style="background:rgba(255,255,255,0.08); color:#60a5fa;">sub_RLM</code> on context portions — divide and conquer at any depth</div>
      </div>
    </div>
  </div>
</div>

<!--
NOTAS — The 3 Defining Properties of RLM (1/3)

El contexto vive como variable P en el REPL. El LLM solo ve metadatos: longitud, prefijo. Para leer el contenido, escribe código. Nunca entra en el prompt.
CodeAct mete el contexto en el prompt → falla aquí.
→ ¿Dónde vive ese código? En un entorno persistente.
-->

---

# 🏗️ The 3 Defining Properties of RLM

From the paper (MIT CSAIL 2025):

<div style="display:flex; flex-direction:column; gap:10px; margin-top:14px;">
  <div style="display:flex; align-items:stretch; gap:12px;">
    <div style="background:rgba(234,179,8,0.15); border:2px solid #eab308; border-radius:12px; padding:14px 16px; flex:1; display:flex; align-items:center; gap:14px;">
      <div style="font-size:2em; min-width:48px; text-align:center !important;">📌</div>
      <div>
        <div style="font-size:1.05em; font-weight:700; color:#fde68a;">1 · Symbolic handle to the prompt</div>
        <div style="font-size:0.85em; color:#94a3b8; margin-top:2px;">Context stored as variable <code style="background:rgba(255,255,255,0.08); color:#fbbf24;">P</code> in memory — never inside the neural network</div>
      </div>
    </div>
  </div>
  <div style="display:flex; align-items:stretch; gap:12px;">
    <div style="background:rgba(34,197,94,0.12); border:2px solid #22c55e; border-radius:12px; padding:14px 16px; flex:1; display:flex; align-items:center; gap:14px;">
      <div style="font-size:2em; min-width:48px; text-align:center !important;">⚙️</div>
      <div>
        <div style="font-size:1.05em; font-weight:700; color:#86efac;">2 · Persistent Turing-complete environment</div>
        <div style="font-size:0.85em; color:#94a3b8; margin-top:2px;">Python REPL that persists across iterations — define functions, accumulate state, build logic</div>
      </div>
    </div>
  </div>
  <div style="display:flex; align-items:stretch; gap:12px; visibility:hidden;">
    <div style="background:rgba(96,165,250,0.15); border:2px solid #3b82f6; border-radius:12px; padding:14px 16px; flex:1; display:flex; align-items:center; gap:14px;">
      <div style="font-size:2em; min-width:48px; text-align:center !important;">🔄</div>
      <div>
        <div style="font-size:1.05em; font-weight:700; color:#93c5fd;">3 · Symbolic recursion</div>
        <div style="font-size:0.85em; color:#94a3b8; margin-top:2px;">LLM calls itself via <code style="background:rgba(255,255,255,0.08); color:#60a5fa;">sub_RLM</code> on context portions — divide and conquer at any depth</div>
      </div>
    </div>
  </div>
</div>

<!--
NOTAS — The 3 Defining Properties of RLM (2/3)

El REPL persiste entre iteraciones: variables, funciones, estado acumulado. No es one-shot, es un loop iterativo. El modelo construye su solución paso a paso.
Summary agents comprimen y pierden info → fallan aquí.
→ Y cuando el problema es tan grande que ni el REPL puede de una vez...
-->

---

# 🏗️ The 3 Defining Properties of RLM

From the paper (MIT CSAIL 2025):

<div style="display:flex; flex-direction:column; gap:10px; margin-top:14px;">
  <div style="display:flex; align-items:stretch; gap:12px;">
    <div style="background:rgba(234,179,8,0.15); border:2px solid #eab308; border-radius:12px; padding:14px 16px; flex:1; display:flex; align-items:center; gap:14px;">
      <div style="font-size:2em; min-width:48px; text-align:center !important;">📌</div>
      <div>
        <div style="font-size:1.05em; font-weight:700; color:#fde68a;">1 · Symbolic handle to the prompt</div>
        <div style="font-size:0.85em; color:#94a3b8; margin-top:2px;">Context stored as variable <code style="background:rgba(255,255,255,0.08); color:#fbbf24;">P</code> in memory — never inside the neural network</div>
      </div>
    </div>
  </div>
  <div style="display:flex; align-items:stretch; gap:12px;">
    <div style="background:rgba(34,197,94,0.12); border:2px solid #22c55e; border-radius:12px; padding:14px 16px; flex:1; display:flex; align-items:center; gap:14px;">
      <div style="font-size:2em; min-width:48px; text-align:center !important;">⚙️</div>
      <div>
        <div style="font-size:1.05em; font-weight:700; color:#86efac;">2 · Persistent Turing-complete environment</div>
        <div style="font-size:0.85em; color:#94a3b8; margin-top:2px;">Python REPL that persists across iterations — define functions, accumulate state, build logic</div>
      </div>
    </div>
  </div>
  <div style="display:flex; align-items:stretch; gap:12px;">
    <div style="background:rgba(96,165,250,0.15); border:2px solid #3b82f6; border-radius:12px; padding:14px 16px; flex:1; display:flex; align-items:center; gap:14px;">
      <div style="font-size:2em; min-width:48px; text-align:center !important;">🔄</div>
      <div>
        <div style="font-size:1.05em; font-weight:700; color:#93c5fd;">3 · Symbolic recursion</div>
        <div style="font-size:0.85em; color:#94a3b8; margin-top:2px;">LLM calls itself via <code style="background:rgba(255,255,255,0.08); color:#60a5fa;">sub_RLM</code> on context portions — divide and conquer at any depth</div>
      </div>
    </div>
  </div>
</div>

<!--
NOTAS — The 3 Defining Properties of RLM (3/3)

llm_query() lanza un RLM hijo con su propio REPL. Divide y vencerás a cualquier profundidad. Esto es lo que permite escalar a 10M+ tokens.
Si falta una sola de las 3 → no es un RLM. CodeAct falla la 1ª, Summary agents la 2ª, ReAct la 3ª.
→ Veamos cómo encaja todo en la arquitectura.
-->

---

<div style="font-size:1em; color:#93c5fd; font-weight:600; margin-bottom:8px;">🎯 Architecture: RLM High-Level View</div>
<br/>

<table style="width:100%; border-collapse:separate; border-spacing:0; background:rgba(30,58,95,0.5); border:2px solid #3b82f6; border-radius:14px;">
  <tr><td colspan="5" style="border:none; padding:8px 14px; font-size:20px; font-weight:800; color:#93c5fd;">RLM (root / depth = 0)</td></tr>
  <!-- Row 1: query → LM → response -->
  <tr style="vertical-align:middle;">
    <td style="border:none; padding:8px 10px; width:16%; text-align:center;">
      <div style="background:rgba(234,179,8,0.15); border:2px solid #eab308; color:#fde68a; border-radius:10px; padding:12px; font-weight:600; font-size:20px;">📋 query</div>
    </td>
    <td style="border:none; width:9%; text-align:center;">
      <span style="font-size:26px; color:#94a3b8;">→</span><br>
      <span style="font-size:10px; color:#94a3b8;">system prompt<br>+ P metadata</span>
    </td>
    <td style="border:none; padding:8px 10px; text-align:center;" rowspan="3">
      <div style="background:rgba(34,197,94,0.15); border:2px solid #22c55e; color:#86efac; border-radius:10px; padding:12px; font-weight:600; font-size:22px; margin-bottom:8px;">🧠 Language Model</div>
      <div style="font-size:18px; color:#94a3b8; margin-bottom:8px;">code ↓ &nbsp;&nbsp;<span style="font-size:30px; color:#60a5fa; font-weight:900;">⟳</span>&nbsp;&nbsp; ↑ stdout</div>
      <div style="background:rgba(239,68,68,0.15); border:2px solid #ef4444; color:#fca5a5; border-radius:10px; padding:12px; font-weight:600; font-size:20px;">
        ⚙️ Environment E (Python REPL)<br>
        <span style="font-size:14px; font-weight:400; color:#cbd5e1;">P = context · llm_query() · extract_after() · peek()</span>
      </div>
    </td>
    <td style="border:none; width:6%; text-align:center;" rowspan="3">
      <span style="font-size:28px; color:#94a3b8;">→</span>
    </td>
    <td style="border:none; padding:8px 10px; width:16%; text-align:center;" rowspan="3">
      <div style="background:rgba(168,85,247,0.15); border:2px solid #a855f7; color:#d8b4fe; border-radius:10px; padding:12px; font-weight:600; font-size:20px;">✅ final<br>response</div>
      <div style="font-size:13px; color:#94a3b8; font-style:italic; margin-top:6px;">FINAL: / FINAL_VAR:</div>
    </td>
  </tr>
  <!-- Row 2: spacer -->
  <tr>
    <td style="border:none; padding:6px;"></td>
    <td style="border:none;"></td>
  </tr>
  <!-- Row 3: context → Environment -->
  <tr style="vertical-align:middle;">
    <td style="border:none; padding:8px 10px; text-align:center;">
      <div style="background:rgba(234,179,8,0.15); border:2px solid #eab308; color:#fde68a; border-radius:10px; padding:12px; font-weight:600; font-size:20px;">📄 context<br><span style="font-size:15px; font-weight:400;">(1M tokens)</span></div>
    </td>
    <td style="border:none; text-align:center;">
      <span style="font-size:26px; color:#94a3b8;">→</span><br>
      <span style="font-size:12px; color:#94a3b8;">var P</span>
    </td>
  </tr>
  <tr><td colspan="5" style="border:none; text-align:center; padding:8px 0; font-size:16px; color:#94a3b8;">
    REPL calls <code style="color:#f87171; font-weight:700; background:transparent;">llm_query(sub_context)</code> → spawns child RLMs ↓
  </td></tr>
</table>

<!--
El context en RLM no es input, es memoria accesible bajo demanda.

El contexto NO se envía al LLM — se almacena como variable P en el REPL. El LLM solo ve metadata: longitud, estructura, nº de documentos.
El LLM genera código → se ejecuta en el REPL → stdout vuelve al LLM. El loop termina cuando emite FINAL: o FINAL_VAR:.
Cuando llama a llm_query(sub_context), se crea un RLM hijo con su propio REPL — recursión arbitraria. Es como un programador que no carga un archivo gigante en RAM: lo abre, busca con grep, y delega trozos.
-->

---

<div style="font-size:0.75em; color:#93c5fd; font-weight:600; margin-bottom:6px;">🎯 Architecture: RLM High-Level View — Recursive Children</div>
<br/>

<div style="display:flex; flex-direction:column; gap:10px;">

  <!-- Child 1 -->
  <div style="flex:1; background:rgba(148,163,184,0.08); border:2px dashed #64748b; border-radius:12px; padding:12px;">
    <div style="font-size:18px; font-weight:700; color:#cbd5e1; margin-bottom:8px; text-align:center;">RLM (depth=1)</div>
    <table style="width:100%; border-collapse:collapse;">
      <tr style="vertical-align:middle;">
        <td style="border:none; text-align:center; width:30%; padding:5px;">
          <div style="background:rgba(234,179,8,0.15); border:1px solid #eab308; color:#fde68a; border-radius:8px; padding:8px; font-size:17px; font-weight:600;">📋 sub-query</div>
        </td>
        <td style="border:none; text-align:center; width:8%; font-size:18px; color:#94a3b8; padding:5px;">→<br><span style="font-size:12px;">hist</span></td>
        <td style="border:none; text-align:center; padding:5px;" rowspan="3">
          <div style="background:rgba(34,197,94,0.15); border:1px solid #22c55e; color:#86efac; border-radius:8px; padding:8px; font-size:17px; font-weight:600; margin-bottom:6px;">🧠 LM</div>
          <div style="font-size:14px; color:#94a3b8;">code <span style="color:#60a5fa; font-size:18px;">⟳</span> stdout</div>
          <div style="background:rgba(239,68,68,0.15); border:1px solid #ef4444; color:#fca5a5; border-radius:8px; padding:8px; font-size:17px; font-weight:600; margin-top:6px;">⚙️ REPL (P)</div>
        </td>
        <td style="border:none; text-align:center; width:8%; font-size:18px; color:#94a3b8; padding:5px;" rowspan="3">→</td>
        <td style="border:none; text-align:center; width:26%; padding:5px;" rowspan="3">
          <div style="background:rgba(168,85,247,0.15); border:1px solid #a855f7; color:#d8b4fe; border-radius:8px; padding:8px; font-size:17px; font-weight:600;">✅ result</div>
          <div style="font-size:12px; color:#94a3b8; margin-top:4px;">→ parent REPL<br>as variable</div>
        </td>
      </tr>
      <tr><td style="border:none; padding:3px;"></td><td style="border:none;"></td></tr>
      <tr style="vertical-align:middle;">
        <td style="border:none; text-align:center; padding:5px;">
          <div style="background:rgba(234,179,8,0.15); border:1px solid #eab308; color:#fde68a; border-radius:8px; padding:8px; font-size:17px; font-weight:600;">📄 sub-context</div>
        </td>
        <td style="border:none; text-align:center; font-size:18px; color:#94a3b8; padding:5px;">→<br><span style="font-size:12px;">var P</span></td>
      </tr>
    </table>
    <div style="text-align:center; margin-top:8px; font-size:13px; color:#64748b;">can spawn depth=2 children ↓</div>
  </div>

  <!-- Child 2 -->
  <div style="flex:1; background:rgba(148,163,184,0.08); border:2px dashed #64748b; border-radius:12px; padding:12px;">
    <div style="font-size:18px; font-weight:700; color:#cbd5e1; margin-bottom:8px; text-align:center;">RLM (depth=1)</div>
    <table style="width:100%; border-collapse:collapse;">
      <tr style="vertical-align:middle;">
        <td style="border:none; text-align:center; width:30%; padding:5px;">
          <div style="background:rgba(234,179,8,0.15); border:1px solid #eab308; color:#fde68a; border-radius:8px; padding:8px; font-size:17px; font-weight:600;">📋 sub-query</div>
        </td>
        <td style="border:none; text-align:center; width:8%; font-size:18px; color:#94a3b8; padding:5px;">→<br><span style="font-size:12px;">hist</span></td>
        <td style="border:none; text-align:center; padding:5px;" rowspan="3">
          <div style="background:rgba(34,197,94,0.15); border:1px solid #22c55e; color:#86efac; border-radius:8px; padding:8px; font-size:17px; font-weight:600; margin-bottom:6px;">🧠 LM</div>
          <div style="font-size:14px; color:#94a3b8;">code <span style="color:#60a5fa; font-size:18px;">⟳</span> stdout</div>
          <div style="background:rgba(239,68,68,0.15); border:1px solid #ef4444; color:#fca5a5; border-radius:8px; padding:8px; font-size:17px; font-weight:600; margin-top:6px;">⚙️ REPL (P)</div>
        </td>
        <td style="border:none; text-align:center; width:8%; font-size:18px; color:#94a3b8; padding:5px;" rowspan="3">→</td>
        <td style="border:none; text-align:center; width:26%; padding:5px;" rowspan="3">
          <div style="background:rgba(168,85,247,0.15); border:1px solid #a855f7; color:#d8b4fe; border-radius:8px; padding:8px; font-size:17px; font-weight:600;">✅ result</div>
          <div style="font-size:12px; color:#94a3b8; margin-top:4px;">→ parent REPL<br>as variable</div>
        </td>
      </tr>
      <tr><td style="border:none; padding:3px;"></td><td style="border:none;"></td></tr>
      <tr style="vertical-align:middle;">
        <td style="border:none; text-align:center; padding:5px;">
          <div style="background:rgba(234,179,8,0.15); border:1px solid #eab308; color:#fde68a; border-radius:8px; padding:8px; font-size:17px; font-weight:600;">📄 sub-context</div>
        </td>
        <td style="border:none; text-align:center; font-size:18px; color:#94a3b8; padding:5px;">→<br><span style="font-size:12px;">var P</span></td>
      </tr>
    </table>
    <div style="text-align:center; margin-top:8px; font-size:13px; color:#64748b;">can spawn depth=2 children ↓</div>
  </div>

  <!-- ellipsis -->
  <div style="text-align:center; font-size:22px; color:#475569; letter-spacing:8px;">⋯</div>

</div>

<div style="text-align:center; margin-top:8px; font-size:14px; color:#94a3b8;">
  Root REPL: <code style="color:#f87171; font-weight:700; background:transparent;">r1 = llm_query(chunk1) &nbsp;·&nbsp; r2 = llm_query(chunk2) &nbsp;·&nbsp; ...</code>
</div>

---

<!-- slide: newspaper clippings -->
<div style="position:relative; width:100%; height:88%; display:flex; flex-wrap:wrap; align-items:center; justify-content:center; gap:16px; padding:6px;">

  <div style="transform:rotate(-4deg); box-shadow:3px 4px 12px rgba(0,0,0,0.5); background:#f5f0e8; padding:8px 8px 32px 8px; flex-shrink:0;">
    <img src="images/prime-intellect.png" style="display:block; max-height:290px; max-width:330px; object-fit:cover;">
  </div>

  <div style="transform:rotate(-10deg); box-shadow:4px 5px 14px rgba(0,0,0,0.5); background:#fefefe; padding:8px 8px 36px 8px; flex-shrink:0; margin-top:-20px;">
    <img src="images/rlm-google-adk.png" style="display:block; max-height:420px; max-width:500px; object-fit:cover;">
  </div>

  <div style="transform:rotate(-1.8deg); box-shadow:2px 6px 10px rgba(0,0,0,0.45); background:#f8f4ee; padding:8px 8px 28px 8px; flex-shrink:0; margin-top:16px;">
    <img src="images/x-yoav-goldberg.png" style="display:block; max-height:280px; max-width:320px; object-fit:cover;">
  </div>

  <div style="transform:rotate(3.2deg); box-shadow:5px 3px 13px rgba(0,0,0,0.5); background:#fffdf5; padding:8px 8px 34px 8px; flex-shrink:0; margin-top:-10px;">
    <img src="images/chen-sun.png" style="display:block; max-height:280px; max-width:320px; object-fit:cover;">
  </div>

  <div style="transform:rotate(-2.5deg); box-shadow:3px 5px 11px rgba(0,0,0,0.48); background:#f6f1eb; padding:8px 8px 30px 8px; flex-shrink:0; margin-top:10px;">
    <img src="images/joel-niklaus.png" style="display:block; max-height:285px; max-width:325px; object-fit:cover;">
  </div>

</div>

<!--
NOTAS — Newspaper clippings

El paper salió en enero 2026 y en pocas semanas ya estaba generando conversación en toda la industria.
Prime Intellect, Google ADK, Yoav Goldberg, la comunidad de ML — todos reaccionando al mismo paper.
→ Veamos ahora cómo funciona por dentro — el loop iterativo que hace posible todo esto.
-->

---

<table style="width:100%; border-collapse:collapse; margin-top:6px;">
<tr style="vertical-align:top;">

<!-- LEFT: LM flow -->
<td style="border:none; width:32%; padding-right:10px;">
  <div style="font-size:0.75em; color:#93c5fd; font-weight:700; margin-bottom:10px;">🔄 The Iterative REPL Loop</div>
  <div style="display:flex; flex-direction:column; gap:6px;">
    <div style="background:rgba(34,197,94,0.15); border:2px solid #22c55e; color:#86efac; border-radius:10px; padding:12px; text-align:center; font-weight:600; font-size:19px;">
      🧠 Root LM <span style="font-size:14px; font-weight:400; color:#94a3b8;">(depth=0)</span>
    </div>
    <div style="text-align:center; font-size:14px; color:#94a3b8;">↓</div>
    <div style="background:rgba(234,179,8,0.15); border:2px solid #f59e0b; border-radius:8px; padding:9px 12px; font-size:15px; color:#fde68a;">
      <strong>System prompt:</strong><br><span style="color:#cbd5e1; font-size:14px;">"Answer {query}. Interact with REPL..."</span>
    </div>
    <div style="text-align:center; font-size:14px; color:#94a3b8;">↓</div>
    <div style="background:rgba(34,197,94,0.1); border:2px solid #22c55e; border-radius:8px; padding:9px 12px; font-size:15px; color:#86efac;">
      <strong>LM generates code directly:</strong><br>
      <code style="font-size:14px; background:#0f172a; color:#a5f3fc; padding:2px 6px; border-radius:3px;">part1, part2 = prompt.split("Ch.2")</code>
    </div>
    <div style="text-align:center; font-size:14px; color:#94a3b8;">↓ Metadata(stdout)</div>
    <div style="background:rgba(239,68,68,0.1); border:2px solid #ef4444; border-radius:8px; padding:9px 12px; font-size:15px; color:#fca5a5;">
      <strong>hist ← hist ∥ code ∥ Metadata(stdout)</strong><br>
      <span style="font-family:monospace; font-size:13px; color:#cbd5e1;">len=312, prefix="You are reading..."</span>
    </div>
    <div style="text-align:center; margin:5px 0;">
      <span style="font-size:30px; color:#60a5fa; font-weight:900;">⟳</span><br>
      <span style="font-size:13px; color:#94a3b8;">until <code style="background:transparent; color:#60a5fa;">state[Final]</code></span>
    </div>
    <div style="text-align:center; font-size:14px; color:#94a3b8;">↓</div>
    <div style="background:rgba(168,85,247,0.15); border:2px solid #a855f7; border-radius:8px; padding:9px 12px; font-size:15px; color:#d8b4fe;">
      <strong>Final =</strong> <code style="font-size:14px; background:#0f172a; color:#c4b5fd; padding:2px 6px; border-radius:3px;">pre_cats + post_cats</code>
    </div>
  </div>
</td>

<!-- MIDDLE: arrows -->
<td style="border:none; width:8%; vertical-align:middle; text-align:center;">
  <div style="display:flex; flex-direction:column; align-items:center; gap:14px;">
    <div>
      <div style="font-size:13px; color:#86efac; margin-bottom:3px;">code</div>
      <div style="font-size:32px; color:#86efac; line-height:1;">⟶</div>
    </div>
    <div>
      <div style="font-size:32px; color:#fca5a5; line-height:1;">⟵</div>
      <div style="font-size:13px; color:#fca5a5; margin-top:3px;">stdout</div>
    </div>
  </div>
</td>

<!-- RIGHT: REPL -->
<td style="border:none; padding-left:10px;">
  <div style="font-size:20px; font-weight:800; color:#e2e8f0; font-family:'Consolas',monospace; margin-bottom:12px;">⚙️ REPL (Python)</div>

  <div style="font-size:16px; font-weight:700; color:#94a3b8;">In[1]</div>
  <div style="background:#0f172a; color:#a5f3fc; font-family:'Consolas',monospace; font-size:15px; padding:10px 14px; border-radius:6px; line-height:1.6; text-align:left !important;">
    <span style="color:#6ee7b7;"># prompt is P — a string, never sent to LM</span><br>
    print(prompt[:100])
  </div>
  <div style="background:rgba(148,163,184,0.1); border:1px solid #475569; border-radius:6px; padding:7px 12px; font-size:14px; font-family:monospace; color:#cbd5e1; text-align:left !important; margin:4px 0 10px;">
    Out[1]: "You are reading an extremely long book..."
  </div>

  <div style="font-size:16px; font-weight:700; color:#94a3b8;">In[2]</div>
  <div style="background:#0f172a; color:#a5f3fc; font-family:'Consolas',monospace; font-size:15px; padding:10px 14px; border-radius:6px; line-height:1.6; text-align:left !important;">
    part1, part2 = prompt.split(<span style="color:#fcd34d;">"Chapter 2"</span>)<br>
    pre_cats = <span style="color:#fbbf24; font-weight:700;">llm_query</span>(<span style="color:#fcd34d;">"find items in Ch1"</span>, part1)<br>
    post_cats = <span style="color:#fbbf24; font-weight:700;">llm_query</span>(<span style="color:#fcd34d;">"find items in Ch2+"</span>, part2)
  </div>
  <div style="background:rgba(234,179,8,0.1); border:1px solid #f59e0b; border-radius:6px; padding:6px 12px; font-size:14px; font-family:monospace; color:#fde68a; text-align:left !important; margin:4px 0 10px;">
    ↗️ spawns RLM (depth=1) × 2
  </div>

  <div style="text-align:center; font-size:22px; color:#64748b; letter-spacing:4px;">⋮</div>

  <div style="font-size:16px; font-weight:700; color:#94a3b8;">In[N]</div>
  <div style="background:#0f172a; color:#a5f3fc; font-family:'Consolas',monospace; font-size:15px; padding:10px 14px; border-radius:6px; line-height:1.6; text-align:left !important;">
    <span style="color:#6ee7b7;"># Assign Final — terminates the loop</span><br>
    Final = pre_cats + <span style="color:#fcd34d;">"\n"</span> + post_cats
  </div>
</td>

</tr>
</table>

<!--
NOTAS — The Iterative REPL Loop

Esto es el Algorithm 1 del paper — el corazón del RLM. El contexto (P) NO está en el system prompt, está en el REPL como variable.
El LM produce código Python crudo en cada iteración — no wrappers, no acciones explícitas. El hist acumula código + Metadata(stdout) para que el modelo se autocorrija.
El loop termina cuando el LM escribe `Final = respuesta` — una asignación Python normal, no una función especial.
→ Vamos a ver esto en acción con un ejemplo concreto.
-->

---

# 🔍 Example: Needle in Haystack

**Task:** Find "The key term is: oolong" in 1M tokens

<div class="columns">
<div>

**Baseline (fails):**

```python
# Truncates at 128K tokens
answer = llm("Find key in: " +
             context[:128000])
# Key was at position 500K
# ❌ Lost in truncation
```

</div>
<div>

**RLM (succeeds):**

```python
# Phase 0: Try deterministic
key = extract_after('key term is:')
if key: return key  # ✅ 0 subcalls!

# Phase 1: If needed, chunk & search
chunks = ctx.chunk(5000)
answers = ask_chunks(
    "Extract key", chunks
)
return pick_first_answer(answers)
```

</div>
</div>

<!--
NOTAS — Example: Needle in Haystack

El baseline trunca a 128K tokens — si la aguja está en la posición 500K, se pierde para siempre.
El RLM primero intenta extract_after() determinista: búsqueda de string pura, 0 subcalls, coste $0. Si falla, divide en chunks y hace subcalls al LLM solo donde hace falta.
En S-NIAH del paper, RLM(GPT-5) mantiene ~95% a 1M tokens mientras GPT-5 base degrada a ~80% y no puede ir más allá de 262K.
-->

---

<div style="font-size:0.6em; color:#60a5fa; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:2px;">RLM(GPT-5) vs GPT-5 Base — Accuracy (%)</div>
<div style="display:flex; gap:18px; justify-content:flex-end; font-size:0.65em; color:#94a3b8; margin-bottom:2px;">
  <span><span style="display:inline-block; width:10px; height:10px; background:#60a5fa; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>RLM(GPT-5)</span>
  <span><span style="display:inline-block; width:10px; height:10px; background:#475569; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>GPT-5 direct</span>
</div>

<svg viewBox="0 0 700 275" xmlns="http://www.w3.org/2000/svg" style="width:100%; max-height:550px;">
  <line x1="65" y1="250" x2="685" y2="250" stroke="#334155" stroke-width="1.5"/>
  <line x1="65" y1="15" x2="65" y2="250" stroke="#334155" stroke-width="1"/>
  <line x1="65" y1="191" x2="685" y2="191" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="133" x2="685" y2="133" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="74"  x2="685" y2="74"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="15"  x2="685" y2="15"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <text x="60" y="254" text-anchor="end" fill="#64748b" font-size="11">0</text>
  <text x="60" y="195" text-anchor="end" fill="#64748b" font-size="11">25</text>
  <text x="60" y="137" text-anchor="end" fill="#64748b" font-size="11">50</text>
  <text x="60" y="78"  text-anchor="end" fill="#64748b" font-size="11">75</text>
  <text x="60" y="19"  text-anchor="end" fill="#64748b" font-size="11">100</text>
  <text x="143" y="268" text-anchor="middle" fill="#ffffff" font-weight="bold" font-size="14">CodeQA</text>
  <text x="298" y="268" text-anchor="middle" fill="#1e3a5a" font-size="13">BrowseComp+</text>
  <text x="453" y="268" text-anchor="middle" fill="#1e3a5a" font-size="13">OOLONG</text>
  <text x="608" y="268" text-anchor="middle" fill="#1e3a5a" font-size="13">OOLONG-Pairs</text>
</svg>

<div style="background:rgba(96,165,250,0.08); border-left:3px solid #60a5fa; border-radius:0 6px 6px 0; padding:6px 14px; font-size:0.72em; color:#e2e8f0; margin-top:3px;">
  <strong style="color:#60a5fa;">CodeQA</strong> — Q&amp;A over long documents and codebases (23K–4.2M tokens). Tests retrieval and multi-hop reasoning at scale.
</div>

<!-- NOTAS — Slide: CodeQA intro
LongBench-v2 CodeQA — comprensión de repositorios de código. El modelo recibe un codebase completo y responde preguntas de opción múltiple sobre múltiples ficheros. Contextos de 23K a 4.2M tokens.
GPT-5 direct = GPT-5 llamado directamente, limitado a ~272K tokens. RLM(GPT-5) = GPT-5 como raíz en el REPL loop, con GPT-5-mini para los subcalls recursivos.
→ GPT-5 direct 24%* → RLM(GPT-5) 62%.
-->

---

<div style="font-size:0.6em; color:#60a5fa; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:2px;">RLM(GPT-5) vs GPT-5 Base — Accuracy (%)</div>
<div style="display:flex; gap:18px; justify-content:flex-end; font-size:0.65em; color:#94a3b8; margin-bottom:2px;">
  <span><span style="display:inline-block; width:10px; height:10px; background:#60a5fa; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>RLM(GPT-5)</span>
  <span><span style="display:inline-block; width:10px; height:10px; background:#475569; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>GPT-5 direct</span>
</div>

<svg viewBox="0 0 700 275" xmlns="http://www.w3.org/2000/svg" style="width:100%; max-height:550px;">
  <line x1="65" y1="250" x2="685" y2="250" stroke="#334155" stroke-width="1.5"/>
  <line x1="65" y1="15" x2="65" y2="250" stroke="#334155" stroke-width="1"/>
  <line x1="65" y1="191" x2="685" y2="191" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="133" x2="685" y2="133" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="74"  x2="685" y2="74"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="15"  x2="685" y2="15"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <text x="60" y="254" text-anchor="end" fill="#64748b" font-size="11">0</text>
  <text x="60" y="195" text-anchor="end" fill="#64748b" font-size="11">25</text>
  <text x="60" y="137" text-anchor="end" fill="#64748b" font-size="11">50</text>
  <text x="60" y="78"  text-anchor="end" fill="#64748b" font-size="11">75</text>
  <text x="60" y="19"  text-anchor="end" fill="#64748b" font-size="11">100</text>
  <rect x="96" y="104" width="44" height="146" fill="#60a5fa" rx="3"/>
  <text x="118" y="98" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">62</text>
  <rect x="146" y="194" width="44" height="56" fill="#475569" rx="3"/>
  <text x="168" y="188" text-anchor="middle" fill="#94a3b8" font-size="12">24</text>
  <text x="143" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">CodeQA</text>
  <text x="298" y="268" text-anchor="middle" fill="#ffffff" font-weight="bold" font-size="14">BrowseComp+</text>
  <text x="453" y="268" text-anchor="middle" fill="#1e3a5a" font-size="13">OOLONG</text>
  <text x="608" y="268" text-anchor="middle" fill="#1e3a5a" font-size="13">OOLONG-Pairs</text>
</svg>

<div style="background:rgba(34,197,94,0.08); border-left:3px solid #22c55e; border-radius:0 6px 6px 0; padding:6px 14px; font-size:0.72em; color:#e2e8f0; margin-top:3px;">
  <strong style="color:#60a5fa;">CodeQA</strong> — RLM(GPT-5) <strong style="color:#22c55e;">62%</strong> vs GPT-5 direct 24%* — <strong style="color:#22c55e;">2.6× better</strong>
</div>

<!-- NOTAS — Slide: CodeQA revelado
RLM(GPT-5) 62% vs GPT-5 direct 24%*. El asterisco significa que GPT-5 alcanzó su límite de ventana en muchos casos.
2.6× mejor en un benchmark donde GPT-5 ya puede intentarlo. Cuando el contexto supera la ventana, la ventaja se dispara aún más.
→ Ahora vamos a ver qué pasa con contextos de 6 a 11 millones de tokens.
-->

---

<div style="font-size:0.6em; color:#60a5fa; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:2px;">RLM(GPT-5) vs GPT-5 Base — Accuracy (%)</div>
<div style="display:flex; gap:18px; justify-content:flex-end; font-size:0.65em; color:#94a3b8; margin-bottom:2px;">
  <span><span style="display:inline-block; width:10px; height:10px; background:#60a5fa; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>RLM(GPT-5)</span>
  <span><span style="display:inline-block; width:10px; height:10px; background:#475569; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>GPT-5 direct</span>
</div>

<svg viewBox="0 0 700 275" xmlns="http://www.w3.org/2000/svg" style="width:100%; max-height:550px;">
  <line x1="65" y1="250" x2="685" y2="250" stroke="#334155" stroke-width="1.5"/>
  <line x1="65" y1="15" x2="65" y2="250" stroke="#334155" stroke-width="1"/>
  <line x1="65" y1="191" x2="685" y2="191" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="133" x2="685" y2="133" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="74"  x2="685" y2="74"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="15"  x2="685" y2="15"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <text x="60" y="254" text-anchor="end" fill="#64748b" font-size="11">0</text>
  <text x="60" y="195" text-anchor="end" fill="#64748b" font-size="11">25</text>
  <text x="60" y="137" text-anchor="end" fill="#64748b" font-size="11">50</text>
  <text x="60" y="78"  text-anchor="end" fill="#64748b" font-size="11">75</text>
  <text x="60" y="19"  text-anchor="end" fill="#64748b" font-size="11">100</text>
  <rect x="96" y="104" width="44" height="146" fill="#60a5fa" rx="3"/>
  <text x="118" y="98" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">62</text>
  <rect x="146" y="194" width="44" height="56" fill="#475569" rx="3"/>
  <text x="168" y="188" text-anchor="middle" fill="#94a3b8" font-size="12">24</text>
  <text x="143" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">CodeQA</text>
  <text x="298" y="268" text-anchor="middle" fill="#ffffff" font-weight="bold" font-size="14">BrowseComp+</text>
  <text x="453" y="268" text-anchor="middle" fill="#1e3a5a" font-size="13">OOLONG</text>
  <text x="608" y="268" text-anchor="middle" fill="#1e3a5a" font-size="13">OOLONG-Pairs</text>
</svg>

<div style="background:rgba(96,165,250,0.08); border-left:3px solid #60a5fa; border-radius:0 6px 6px 0; padding:6px 14px; font-size:0.72em; color:#e2e8f0; margin-top:3px;">
  <strong style="color:#60a5fa;">BrowseComp+</strong> — Multi-hop questions over 1K web documents (6M–11M tokens total). GPT-5 direct: 0% — context too large for any LLM window.
</div>

<!-- NOTAS — Slide: BrowseComp+ intro
BrowseComp-Plus: preguntas multi-salto sobre 1.000 documentos web — 6 a 11 millones de tokens en total.
272K es el límite de GPT-5. BrowseComp+ requiere 6-11M. GPT-5 directo no puede intentarlo → 0%*.
RLM lo resuelve: genera código en el REPL, llm_query() spawna child RLMs sobre subcorpus, el resultado vuelve al REPL padre como variable.
-->

---

<div style="font-size:0.6em; color:#60a5fa; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:2px;">RLM(GPT-5) vs GPT-5 Base — Accuracy (%)</div>
<div style="display:flex; gap:18px; justify-content:flex-end; font-size:0.65em; color:#94a3b8; margin-bottom:2px;">
  <span><span style="display:inline-block; width:10px; height:10px; background:#60a5fa; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>RLM(GPT-5)</span>
  <span><span style="display:inline-block; width:10px; height:10px; background:#475569; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>GPT-5 direct</span>
</div>

<svg viewBox="0 0 700 275" xmlns="http://www.w3.org/2000/svg" style="width:100%; max-height:550px;">
  <line x1="65" y1="250" x2="685" y2="250" stroke="#334155" stroke-width="1.5"/>
  <line x1="65" y1="15" x2="65" y2="250" stroke="#334155" stroke-width="1"/>
  <line x1="65" y1="191" x2="685" y2="191" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="133" x2="685" y2="133" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="74"  x2="685" y2="74"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="15"  x2="685" y2="15"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <text x="60" y="254" text-anchor="end" fill="#64748b" font-size="11">0</text>
  <text x="60" y="195" text-anchor="end" fill="#64748b" font-size="11">25</text>
  <text x="60" y="137" text-anchor="end" fill="#64748b" font-size="11">50</text>
  <text x="60" y="78"  text-anchor="end" fill="#64748b" font-size="11">75</text>
  <text x="60" y="19"  text-anchor="end" fill="#64748b" font-size="11">100</text>
  <rect x="96" y="104" width="44" height="146" fill="#60a5fa" rx="3"/>
  <text x="118" y="98" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">62</text>
  <rect x="146" y="194" width="44" height="56" fill="#475569" rx="3"/>
  <text x="168" y="188" text-anchor="middle" fill="#94a3b8" font-size="12">24</text>
  <rect x="251" y="35" width="44" height="215" fill="#60a5fa" rx="3"/>
  <text x="273" y="29" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">91.3</text>
  <rect x="301" y="248" width="44" height="2" fill="#475569" rx="3"/>
  <text x="323" y="242" text-anchor="middle" fill="#94a3b8" font-size="12">0</text>
  <text x="143" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">CodeQA</text>
  <text x="298" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">BrowseComp+</text>
  <text x="453" y="268" text-anchor="middle" fill="#ffffff" font-weight="bold" font-size="14">OOLONG</text>
  <text x="608" y="268" text-anchor="middle" fill="#1e3a5a" font-size="13">OOLONG-Pairs</text>
</svg>

<div style="background:rgba(34,197,94,0.08); border-left:3px solid #22c55e; border-radius:0 6px 6px 0; padding:6px 14px; font-size:0.72em; color:#e2e8f0; margin-top:3px;">
  <strong style="color:#60a5fa;">BrowseComp+</strong> — RLM(GPT-5) <strong style="color:#22c55e;">91.3%</strong> vs GPT-5 direct 0%* — <strong style="color:#22c55e;">∞ improvement</strong>
</div>

<!-- NOTAS — Slide: BrowseComp+ revelado
RLM(GPT-5) 91.3% vs GPT-5 direct 0%*. El resultado más espectacular del paper.
De 0% a 91.3% simplemente por el cambio de arquitectura. Los subcalls van a GPT-5-mini — coste $0.99/query de media, no prohibitivo.
→ Ahora contextos más manejables — OOLONG con 131K tokens.
-->

---

<div style="font-size:0.6em; color:#60a5fa; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:2px;">RLM(GPT-5) vs GPT-5 Base — Accuracy (%)</div>
<div style="display:flex; gap:18px; justify-content:flex-end; font-size:0.65em; color:#94a3b8; margin-bottom:2px;">
  <span><span style="display:inline-block; width:10px; height:10px; background:#60a5fa; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>RLM(GPT-5)</span>
  <span><span style="display:inline-block; width:10px; height:10px; background:#475569; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>GPT-5 direct</span>
</div>

<svg viewBox="0 0 700 275" xmlns="http://www.w3.org/2000/svg" style="width:100%; max-height:550px;">
  <line x1="65" y1="250" x2="685" y2="250" stroke="#334155" stroke-width="1.5"/>
  <line x1="65" y1="15" x2="65" y2="250" stroke="#334155" stroke-width="1"/>
  <line x1="65" y1="191" x2="685" y2="191" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="133" x2="685" y2="133" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="74"  x2="685" y2="74"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="15"  x2="685" y2="15"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <text x="60" y="254" text-anchor="end" fill="#64748b" font-size="11">0</text>
  <text x="60" y="195" text-anchor="end" fill="#64748b" font-size="11">25</text>
  <text x="60" y="137" text-anchor="end" fill="#64748b" font-size="11">50</text>
  <text x="60" y="78"  text-anchor="end" fill="#64748b" font-size="11">75</text>
  <text x="60" y="19"  text-anchor="end" fill="#64748b" font-size="11">100</text>
  <rect x="96" y="104" width="44" height="146" fill="#60a5fa" rx="3"/>
  <text x="118" y="98" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">62</text>
  <rect x="146" y="194" width="44" height="56" fill="#475569" rx="3"/>
  <text x="168" y="188" text-anchor="middle" fill="#94a3b8" font-size="12">24</text>
  <rect x="251" y="35" width="44" height="215" fill="#60a5fa" rx="3"/>
  <text x="273" y="29" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">91.3</text>
  <rect x="301" y="248" width="44" height="2" fill="#475569" rx="3"/>
  <text x="323" y="242" text-anchor="middle" fill="#94a3b8" font-size="12">0</text>
  <text x="143" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">CodeQA</text>
  <text x="298" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">BrowseComp+</text>
  <text x="453" y="268" text-anchor="middle" fill="#ffffff" font-weight="bold" font-size="14">OOLONG</text>
  <text x="608" y="268" text-anchor="middle" fill="#1e3a5a" font-size="13">OOLONG-Pairs</text>
</svg>

<div style="background:rgba(96,165,250,0.08); border-left:3px solid #60a5fa; border-radius:0 6px 6px 0; padding:6px 14px; font-size:0.72em; color:#e2e8f0; margin-top:3px;">
  <strong style="color:#60a5fa;">OOLONG</strong> — "One-Off Long cONtext": needle-in-a-haystack in 131K token documents. GPT-5 direct: 44% — RLM(GPT-5): 56.5%.
</div>

<!-- NOTAS — Slide: OOLONG intro
OOLONG — razonamiento sobre textos largos que requiere transformar chunks del input y agregar el resultado. Complejidad lineal. Documentos de 131K tokens.
131K cabe en la ventana de GPT-5 → GPT-5 direct llega a 44%. Por eso la ventaja de RLM es menor aquí.
→ RLM mejora con peek() y extract_after() para procesar el contexto en chunks simbólicos.
-->

---

<div style="font-size:0.6em; color:#60a5fa; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:2px;">RLM(GPT-5) vs GPT-5 Base — Accuracy (%)</div>
<div style="display:flex; gap:18px; justify-content:flex-end; font-size:0.65em; color:#94a3b8; margin-bottom:2px;">
  <span><span style="display:inline-block; width:10px; height:10px; background:#60a5fa; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>RLM(GPT-5)</span>
  <span><span style="display:inline-block; width:10px; height:10px; background:#475569; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>GPT-5 direct</span>
</div>

<svg viewBox="0 0 700 275" xmlns="http://www.w3.org/2000/svg" style="width:100%; max-height:550px;">
  <line x1="65" y1="250" x2="685" y2="250" stroke="#334155" stroke-width="1.5"/>
  <line x1="65" y1="15" x2="65" y2="250" stroke="#334155" stroke-width="1"/>
  <line x1="65" y1="191" x2="685" y2="191" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="133" x2="685" y2="133" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="74"  x2="685" y2="74"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="15"  x2="685" y2="15"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <text x="60" y="254" text-anchor="end" fill="#64748b" font-size="11">0</text>
  <text x="60" y="195" text-anchor="end" fill="#64748b" font-size="11">25</text>
  <text x="60" y="137" text-anchor="end" fill="#64748b" font-size="11">50</text>
  <text x="60" y="78"  text-anchor="end" fill="#64748b" font-size="11">75</text>
  <text x="60" y="19"  text-anchor="end" fill="#64748b" font-size="11">100</text>
  <rect x="96" y="104" width="44" height="146" fill="#60a5fa" rx="3"/>
  <text x="118" y="98" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">62</text>
  <rect x="146" y="194" width="44" height="56" fill="#475569" rx="3"/>
  <text x="168" y="188" text-anchor="middle" fill="#94a3b8" font-size="12">24</text>
  <rect x="251" y="35" width="44" height="215" fill="#60a5fa" rx="3"/>
  <text x="273" y="29" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">91.3</text>
  <rect x="301" y="248" width="44" height="2" fill="#475569" rx="3"/>
  <text x="323" y="242" text-anchor="middle" fill="#94a3b8" font-size="12">0</text>
  <rect x="406" y="117" width="44" height="133" fill="#60a5fa" rx="3"/>
  <text x="428" y="111" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">56.5</text>
  <rect x="456" y="147" width="44" height="103" fill="#475569" rx="3"/>
  <text x="478" y="141" text-anchor="middle" fill="#94a3b8" font-size="12">44</text>
  <text x="143" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">CodeQA</text>
  <text x="298" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">BrowseComp+</text>
  <text x="453" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">OOLONG</text>
  <text x="608" y="268" text-anchor="middle" fill="#ffffff" font-weight="bold" font-size="14">OOLONG-Pairs</text>
</svg>

<div style="background:rgba(34,197,94,0.08); border-left:3px solid #22c55e; border-radius:0 6px 6px 0; padding:6px 14px; font-size:0.72em; color:#e2e8f0; margin-top:3px;">
  <strong style="color:#60a5fa;">OOLONG</strong> — RLM(GPT-5) <strong style="color:#22c55e;">56.5%</strong> vs GPT-5 direct 44% — <strong style="color:#22c55e;">1.3× better</strong>
</div>

<!-- NOTAS — Slide: OOLONG revelado
RLM(GPT-5) 56.5% vs GPT-5 direct 44%. +12.5 puntos. Mejora moderada — 131K es manejable para GPT-5.
RLM sigue siendo mejor y más barato incluso cuando el contexto cabe en la ventana.
→ OOLONG-Pairs — donde la complejidad es cuadrática y GPT-5 colapsa.
-->

---

<div style="font-size:0.6em; color:#60a5fa; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:2px;">RLM(GPT-5) vs GPT-5 Base — Accuracy (%)</div>
<div style="display:flex; gap:18px; justify-content:flex-end; font-size:0.65em; color:#94a3b8; margin-bottom:2px;">
  <span><span style="display:inline-block; width:10px; height:10px; background:#60a5fa; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>RLM(GPT-5)</span>
  <span><span style="display:inline-block; width:10px; height:10px; background:#475569; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>GPT-5 direct</span>
</div>

<svg viewBox="0 0 700 275" xmlns="http://www.w3.org/2000/svg" style="width:100%; max-height:550px;">
  <line x1="65" y1="250" x2="685" y2="250" stroke="#334155" stroke-width="1.5"/>
  <line x1="65" y1="15" x2="65" y2="250" stroke="#334155" stroke-width="1"/>
  <line x1="65" y1="191" x2="685" y2="191" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="133" x2="685" y2="133" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="74"  x2="685" y2="74"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="15"  x2="685" y2="15"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <text x="60" y="254" text-anchor="end" fill="#64748b" font-size="11">0</text>
  <text x="60" y="195" text-anchor="end" fill="#64748b" font-size="11">25</text>
  <text x="60" y="137" text-anchor="end" fill="#64748b" font-size="11">50</text>
  <text x="60" y="78"  text-anchor="end" fill="#64748b" font-size="11">75</text>
  <text x="60" y="19"  text-anchor="end" fill="#64748b" font-size="11">100</text>
  <rect x="96" y="104" width="44" height="146" fill="#60a5fa" rx="3"/>
  <text x="118" y="98" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">62</text>
  <rect x="146" y="194" width="44" height="56" fill="#475569" rx="3"/>
  <text x="168" y="188" text-anchor="middle" fill="#94a3b8" font-size="12">24</text>
  <rect x="251" y="35" width="44" height="215" fill="#60a5fa" rx="3"/>
  <text x="273" y="29" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">91.3</text>
  <rect x="301" y="248" width="44" height="2" fill="#475569" rx="3"/>
  <text x="323" y="242" text-anchor="middle" fill="#94a3b8" font-size="12">0</text>
  <rect x="406" y="117" width="44" height="133" fill="#60a5fa" rx="3"/>
  <text x="428" y="111" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">56.5</text>
  <rect x="456" y="147" width="44" height="103" fill="#475569" rx="3"/>
  <text x="478" y="141" text-anchor="middle" fill="#94a3b8" font-size="12">44</text>
  <text x="143" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">CodeQA</text>
  <text x="298" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">BrowseComp+</text>
  <text x="453" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">OOLONG</text>
  <text x="608" y="268" text-anchor="middle" fill="#ffffff" font-weight="bold" font-size="14">OOLONG-Pairs</text>
</svg>

<div style="background:rgba(96,165,250,0.08); border-left:3px solid #60a5fa; border-radius:0 6px 6px 0; padding:6px 14px; font-size:0.72em; color:#e2e8f0; margin-top:3px;">
  <strong style="color:#60a5fa;">OOLONG-Pairs</strong> — Paired comparison: identify differences between two long documents (32K tokens each). GPT-5 direct: 0.1% — two contexts at once is impossible.
</div>

<!-- NOTAS — Slide: OOLONG-Pairs intro
OOLONG-Pairs — razonamiento sobre pares de chunks distribuidos por todo el documento. Complejidad cuadrática. ~32K tokens.
Solo 32K tokens — cabe perfectamente en GPT-5. Pero la complejidad cuadrática de la tarea hace que colapse → 0.1%.
RLM genera código que itera sobre pares de chunks con extract_after() y peek().
-->

---

<div style="font-size:0.6em; color:#60a5fa; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:2px;">RLM(GPT-5) vs GPT-5 Base — Accuracy (%)</div>
<div style="display:flex; gap:18px; justify-content:flex-end; font-size:0.65em; color:#94a3b8; margin-bottom:2px;">
  <span><span style="display:inline-block; width:10px; height:10px; background:#60a5fa; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>RLM(GPT-5)</span>
  <span><span style="display:inline-block; width:10px; height:10px; background:#475569; border-radius:2px; vertical-align:middle; margin-right:3px;"></span>GPT-5 direct</span>
</div>

<svg viewBox="0 0 700 275" xmlns="http://www.w3.org/2000/svg" style="width:100%; max-height:550px;">
  <line x1="65" y1="250" x2="685" y2="250" stroke="#334155" stroke-width="1.5"/>
  <line x1="65" y1="15" x2="65" y2="250" stroke="#334155" stroke-width="1"/>
  <line x1="65" y1="191" x2="685" y2="191" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="133" x2="685" y2="133" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="74"  x2="685" y2="74"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="65" y1="15"  x2="685" y2="15"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <text x="60" y="254" text-anchor="end" fill="#64748b" font-size="11">0</text>
  <text x="60" y="195" text-anchor="end" fill="#64748b" font-size="11">25</text>
  <text x="60" y="137" text-anchor="end" fill="#64748b" font-size="11">50</text>
  <text x="60" y="78"  text-anchor="end" fill="#64748b" font-size="11">75</text>
  <text x="60" y="19"  text-anchor="end" fill="#64748b" font-size="11">100</text>
  <rect x="96" y="104" width="44" height="146" fill="#60a5fa" rx="3"/>
  <text x="118" y="98" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">62</text>
  <rect x="146" y="194" width="44" height="56" fill="#475569" rx="3"/>
  <text x="168" y="188" text-anchor="middle" fill="#94a3b8" font-size="12">24</text>
  <rect x="251" y="35" width="44" height="215" fill="#60a5fa" rx="3"/>
  <text x="273" y="29" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">91.3</text>
  <rect x="301" y="248" width="44" height="2" fill="#475569" rx="3"/>
  <text x="323" y="242" text-anchor="middle" fill="#94a3b8" font-size="12">0</text>
  <rect x="406" y="117" width="44" height="133" fill="#60a5fa" rx="3"/>
  <text x="428" y="111" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">56.5</text>
  <rect x="456" y="147" width="44" height="103" fill="#475569" rx="3"/>
  <text x="478" y="141" text-anchor="middle" fill="#94a3b8" font-size="12">44</text>
  <rect x="561" y="114" width="44" height="136" fill="#60a5fa" rx="3"/>
  <text x="583" y="108" text-anchor="middle" fill="#60a5fa" font-size="12" font-weight="bold">58</text>
  <rect x="611" y="248" width="44" height="2" fill="#475569" rx="3"/>
  <text x="633" y="242" text-anchor="middle" fill="#94a3b8" font-size="12">0.1</text>
  <text x="143" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">CodeQA</text>
  <text x="298" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">BrowseComp+</text>
  <text x="453" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">OOLONG</text>
  <text x="608" y="268" text-anchor="middle" fill="#93c5fd" font-size="13">OOLONG-Pairs</text>
</svg>

<div style="background:rgba(34,197,94,0.08); border-left:3px solid #22c55e; border-radius:0 6px 6px 0; padding:6px 14px; font-size:0.72em; color:#e2e8f0; margin-top:3px;">
  RLM wins on <strong style="color:#22c55e;">every benchmark</strong> — and at a <strong style="color:#22c55e;">lower cost per query</strong> than summary-based agents.
</div>

<!-- NOTAS — Slide: todos los benchmarks — resumen
RLM gana en los 4 benchmarks. Patrón claro: cuanto más larga y compleja la tarea, mayor la ventaja.
OOLONG (lineal) 1.3×, CodeQA (hasta 4.2M) 2.6×, OOLONG-Pairs (cuadrático) 580×, BrowseComp+ (6-11M) ∞.
Coste: RLM(GPT-5) $0.11/query en CodeQA vs Summary Agent $1.31/query — 12× más barato y más preciso.
→ Siguiente slide: degradación por longitud de contexto.
-->

---

<div style="font-size:0.65em; color:#ef4444; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:4px;">Observation 3 — Performance degrades with context length (OOLONG)</div>

<svg viewBox="0 0 680 265" xmlns="http://www.w3.org/2000/svg" style="width:100%; max-height:400px;">
  <!-- Red zone beyond GPT-5 limit (272K ≈ x=496) -->
  <rect x="496" y="20" width="164" height="200" fill="rgba(239,68,68,0.07)"/>
  <!-- Grid -->
  <line x1="70" y1="20"  x2="660" y2="20"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="70" y1="70"  x2="660" y2="70"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="70" y1="120" x2="660" y2="120" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="70" y1="170" x2="660" y2="170" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <!-- Axes -->
  <line x1="70" y1="220" x2="660" y2="220" stroke="#334155" stroke-width="1.5"/>
  <line x1="70" y1="20"  x2="70"  y2="220" stroke="#334155" stroke-width="1"/>
  <!-- Context limit line -->
  <line x1="496" y1="20" x2="496" y2="220" stroke="#ef4444" stroke-width="1.5" stroke-dasharray="5,4" opacity="0.7"/>
  <text x="492" y="16" text-anchor="end" fill="#ef4444" font-size="11" opacity="0.85">GPT-5 limit (272K)</text>
  <!-- Y labels -->
  <text x="65" y="224" text-anchor="end" fill="#64748b" font-size="11">0</text>
  <text x="65" y="174" text-anchor="end" fill="#64748b" font-size="11">25</text>
  <text x="65" y="124" text-anchor="end" fill="#64748b" font-size="11">50</text>
  <text x="65" y="74"  text-anchor="end" fill="#64748b" font-size="11">75</text>
  <text x="65" y="24"  text-anchor="end" fill="#64748b" font-size="11">100</text>
  <!-- X labels -->
  <text x="70"  y="234" text-anchor="middle" fill="#64748b" font-size="10">8K</text>
  <text x="155" y="234" text-anchor="middle" fill="#64748b" font-size="10">16K</text>
  <text x="239" y="234" text-anchor="middle" fill="#64748b" font-size="10">32K</text>
  <text x="324" y="234" text-anchor="middle" fill="#64748b" font-size="10">64K</text>
  <text x="412" y="234" text-anchor="middle" fill="#64748b" font-size="10">131K</text>
  <text x="496" y="234" text-anchor="middle" fill="#ef4444" font-size="10" opacity="0.85">272K</text>
  <text x="581" y="234" text-anchor="middle" fill="#64748b" font-size="10">524K*</text>
  <text x="660" y="234" text-anchor="middle" fill="#64748b" font-size="10">1M*</text>
  <text x="365" y="252" text-anchor="middle" fill="#475569" font-size="11">Input Context Length (log scale)</text>
  <!-- GPT-5 line (red, degrades) -->
  <polyline points="70,100 155,104 239,110 324,116 412,132 496,164 581,196 660,212"
            fill="none" stroke="#ef4444" stroke-width="2.5" stroke-linejoin="round"/>
  <circle cx="70"  cy="100" r="4" fill="#ef4444"/>
  <circle cx="155" cy="104" r="4" fill="#ef4444"/>
  <circle cx="239" cy="110" r="4" fill="#ef4444"/>
  <circle cx="324" cy="116" r="4" fill="#ef4444"/>
  <circle cx="412" cy="132" r="4" fill="#ef4444"/>
  <circle cx="496" cy="164" r="4" fill="#ef4444"/>
  <circle cx="581" cy="196" r="4" fill="#ef4444" opacity="0.5"/>
  <circle cx="660" cy="212" r="4" fill="#ef4444" opacity="0.5"/>
  <!-- RLM(GPT-5) line (blue, flat) -->
  <polyline points="70,104 155,106 239,106 324,108 412,108 496,110 581,108 660,110"
            fill="none" stroke="#60a5fa" stroke-width="2.5" stroke-linejoin="round"/>
  <circle cx="70"  cy="104" r="4" fill="#60a5fa"/>
  <circle cx="155" cy="106" r="4" fill="#60a5fa"/>
  <circle cx="239" cy="106" r="4" fill="#60a5fa"/>
  <circle cx="324" cy="108" r="4" fill="#60a5fa"/>
  <circle cx="412" cy="108" r="4" fill="#60a5fa"/>
  <circle cx="496" cy="110" r="4" fill="#60a5fa"/>
  <circle cx="581" cy="108" r="4" fill="#60a5fa"/>
  <circle cx="660" cy="110" r="4" fill="#60a5fa"/>
</svg>

<div style="display:flex; gap:20px; justify-content:center; font-size:0.7em; color:#94a3b8; margin-top:4px;">
  <span><svg width="24" height="10" style="vertical-align:middle;"><line x1="0" y1="5" x2="18" y2="5" stroke="#ef4444" stroke-width="2.5"/><circle cx="9" cy="5" r="3" fill="#ef4444"/></svg> GPT-5 (direct)</span>
  <span><svg width="24" height="10" style="vertical-align:middle;"><line x1="0" y1="5" x2="18" y2="5" stroke="#60a5fa" stroke-width="2.5"/><circle cx="9" cy="5" r="3" fill="#60a5fa"/></svg> RLM(GPT-5)</span>
</div>

<div style="background:rgba(239,68,68,0.06); border-left:3px solid #ef4444; border-radius:0 6px 6px 0; padding:6px 14px; font-size:0.72em; color:#e2e8f0; margin-top:4px;">
  Past the 272K window (red zone), GPT-5 collapses. <strong style="color:#60a5fa;">RLM(GPT-5)</strong> stays flat at any context length — <em>processing inputs orders of magnitude beyond the base model's limit.</em>
</div>

<!-- NOTAS — Slide: degradación por longitud de contexto
Observation 3 del paper: "LM performance degrades as a function of input length and problem complexity, while RLM performance scales better."
GPT-5 empieza ~60% en OOLONG y declina gradualmente. A partir de 272K colapsa porque no puede procesar la entrada.
RLM(GPT-5) se mantiene plano (~56-58%) desde 8K hasta 1M tokens — la línea es casi horizontal. La zona roja es donde GPT-5 ni puede intentarlo.
-->

---

# 🧠 RLM-Qwen3-8B

<div style="display:flex; gap:14px; margin-top:20px;">
  <div style="flex:1; background:rgba(96,165,250,0.1); border:1px solid #60a5fa; border-radius:12px; padding:20px 16px; text-align:center;">
    <div style="font-size:0.7em; color:#60a5fa; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:10px;">What</div>
    <div style="font-size:0.9em; color:#e2e8f0; line-height:1.5;">Qwen3-8B fine-tuned to <strong>natively operate as an RLM</strong></div>
    <div style="font-size:0.75em; color:#64748b; margin-top:8px;">First small model trained to be an RLM</div>
  </div>
  <div style="flex:1; background:rgba(34,197,94,0.1); border:1px solid #22c55e; border-radius:12px; padding:20px 16px; text-align:center;">
    <div style="font-size:0.7em; color:#22c55e; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:10px;">Result</div>
    <div style="font-size:2.2em; font-weight:800; color:#22c55e;">+28.3%</div>
    <div style="font-size:0.78em; color:#94a3b8; margin-top:4px;">avg vs base Qwen3-8B as RLM</div>
  </div>
  <div style="flex:1; background:rgba(234,179,8,0.1); border:1px solid #eab308; border-radius:12px; padding:20px 16px; text-align:center;">
    <div style="font-size:0.7em; color:#eab308; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:10px;">Training</div>
    <div style="font-size:0.85em; color:#e2e8f0; line-height:1.5;">~1,000 trajectories from <strong>Qwen3-Coder-480B</strong></div>
    <div style="font-size:0.75em; color:#64748b; margin-top:8px;">Domain unrelated to eval benchmarks</div>
  </div>
</div>

<!-- NOTAS — RLM-Qwen3-8B intro
Observation 6 del paper (sección 4, pág 7): "Training RLMs on one domain can improve general downstream RLM performance."

Qué es RLM-Qwen3-8B:
- Es un Qwen3-8B (modelo pequeño de 8B parámetros) que ha sido fine-tuned para operar NATIVAMENTE como un RLM.
- Se entrena con ~1.000 trayectorias RLM generadas por Qwen3-Coder-480B-A35B (60× más grande) actuando como RLM.
- Las tareas de entrenamiento son LongBenchPro — completamente distintas a los benchmarks de evaluación (CodeQA, OOLONG, etc.)

Por qué importa:
- Demuestra que el comportamiento RLM se puede DESTILIAR de un modelo grande a uno pequeño.
- El modelo aprende cuándo hacer subcalls, cómo chunkear, y qué inspeccionar — estrategias que un modelo vanilla ignora.
- Resultado: +28.3% de media respecto a Qwen3-8B base como RLM, con menor coste de inferencia.

Insight clave para el público: no es solo un scaffold alrededor del modelo. El modelo ha APRENDIDO a ser un RLM. El runtime le da la infraestructura, el fine-tuning le da la inteligencia.
-->

---

# 📊 Qwen3-8B: Base vs RLM vs Fine-tuned

<svg viewBox="0 0 700 240" xmlns="http://www.w3.org/2000/svg" style="width:100%; max-height:390px;">
  <!-- Grid lines (bottom=215, top=20, height=195, max=35%, 1%=5.57px) -->
  <line x1="55" y1="20"  x2="675" y2="20"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="55" y1="75"  x2="675" y2="75"  stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="55" y1="131" x2="675" y2="131" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <line x1="55" y1="187" x2="675" y2="187" stroke="#1e293b" stroke-dasharray="4,3" stroke-width="1"/>
  <!-- Axes -->
  <line x1="55" y1="215" x2="675" y2="215" stroke="#334155" stroke-width="1.5"/>
  <line x1="55" y1="20"  x2="55"  y2="215" stroke="#334155" stroke-width="1"/>
  <!-- Y labels -->
  <text x="50" y="218" text-anchor="end" fill="#64748b" font-size="11">0%</text>
  <text x="50" y="190" text-anchor="end" fill="#64748b" font-size="11">5%</text>
  <text x="50" y="134" text-anchor="end" fill="#64748b" font-size="11">15%</text>
  <text x="50" y="78"  text-anchor="end" fill="#64748b" font-size="11">25%</text>
  <text x="50" y="23"  text-anchor="end" fill="#64748b" font-size="11">35%</text>

  <!-- ── GROUP 1: CodeQA · centers at bars: x=99,127,155 ── -->
  <!-- Base 4% → h=22, top=193 -->
  <rect x="99"  y="193" width="22" height="22" fill="#ef4444" rx="2"/>
  <text x="110" y="189" text-anchor="middle" fill="#fca5a5" font-size="10">4%</text>
  <!-- Scaffold 26% → h=145, top=70 -->
  <rect x="127" y="70"  width="22" height="145" fill="#eab308" rx="2"/>
  <text x="138" y="66"  text-anchor="middle" fill="#fde68a" font-size="10">26%</text>
  <!-- Fine-tuned 32% → h=178, top=37 -->
  <rect x="155" y="37"  width="22" height="178" fill="#60a5fa" rx="2"/>
  <text x="166" y="33"  text-anchor="middle" fill="#93c5fd" font-size="10">32%</text>
  <text x="138" y="230" text-anchor="middle" fill="#94a3b8" font-size="12" font-weight="600">CodeQA</text>

  <!-- ── GROUP 2: BrowseComp+ · x=254,282,310 ── -->
  <!-- Base 0% → tiny tick -->
  <line x1="254" y1="215" x2="276" y2="215" stroke="#ef4444" stroke-width="2" opacity="0.5"/>
  <text x="265" y="210" text-anchor="middle" fill="#fca5a5" font-size="10">0%</text>
  <!-- Scaffold 2% → h=11, top=204 -->
  <rect x="282" y="204" width="22" height="11" fill="#eab308" rx="2"/>
  <text x="293" y="200" text-anchor="middle" fill="#fde68a" font-size="10">2%</text>
  <!-- Fine-tuned 14% → h=78, top=137 -->
  <rect x="310" y="137" width="22" height="78" fill="#60a5fa" rx="2"/>
  <text x="321" y="133" text-anchor="middle" fill="#93c5fd" font-size="10">14%</text>
  <text x="293" y="230" text-anchor="middle" fill="#94a3b8" font-size="11">BrowseComp+</text>

  <!-- ── GROUP 3: OOLONG · x=409,437,465 ── -->
  <!-- Base 0% → tiny tick -->
  <line x1="409" y1="215" x2="431" y2="215" stroke="#ef4444" stroke-width="2" opacity="0.5"/>
  <text x="420" y="210" text-anchor="middle" fill="#fca5a5" font-size="10">0%</text>
  <!-- Scaffold 24% → h=134, top=81 -->
  <rect x="437" y="81"  width="22" height="134" fill="#eab308" rx="2"/>
  <text x="448" y="77"  text-anchor="middle" fill="#fde68a" font-size="10">24%</text>
  <!-- Fine-tuned 32% → h=178, top=37 -->
  <rect x="465" y="37"  width="22" height="178" fill="#60a5fa" rx="2"/>
  <text x="476" y="33"  text-anchor="middle" fill="#93c5fd" font-size="10">32%</text>
  <text x="448" y="230" text-anchor="middle" fill="#94a3b8" font-size="12" font-weight="600">OOLONG</text>

  <!-- ── GROUP 4: OOLONG-Pairs · x=564,592,620 ── -->
  <!-- Base 0.1% → h=1 -->
  <rect x="564" y="214" width="22" height="1" fill="#ef4444" rx="1"/>
  <text x="575" y="209" text-anchor="middle" fill="#fca5a5" font-size="10">0.1%</text>
  <!-- Scaffold 4.3% → h=24, top=191 -->
  <rect x="592" y="191" width="22" height="24" fill="#eab308" rx="2"/>
  <text x="603" y="187" text-anchor="middle" fill="#fde68a" font-size="10">4.3%</text>
  <!-- Fine-tuned 5.2% → h=29, top=186 -->
  <rect x="620" y="186" width="22" height="29" fill="#60a5fa" rx="2"/>
  <text x="631" y="182" text-anchor="middle" fill="#93c5fd" font-size="10" style="marginBottom:2px">5.2%</text>
  <text x="603" y="230" text-anchor="middle" fill="#94a3b8" font-size="11">OOLONG-Pairs</text>
</svg>

<div style="display:flex; gap:20px; justify-content:center; font-size:0.7em; color:#94a3b8; margin-top:4px;">
  <span><svg width="22" height="10" style="vertical-align:middle;"><rect x="0" y="1" width="18" height="8" fill="#ef4444" rx="2"/></svg> Base Qwen3-8B</span>
  <span><svg width="22" height="10" style="vertical-align:middle;"><rect x="0" y="1" width="18" height="8" fill="#eab308" rx="2"/></svg> + RLM scaffold</span>
  <span><svg width="22" height="10" style="vertical-align:middle;"><rect x="0" y="1" width="18" height="8" fill="#60a5fa" rx="2"/></svg> RLM fine-tuned</span>
</div>

<!-- NOTAS — Qwen3-8B benchmark chart
Datos de Table 1 del paper (sección Qwen3-8B):
- Base Model: CodeQA 4%*, BrowseComp+ 0%*, OOLONG 0%*, OOLONG-Pairs 0.1% (* = hit context limits)
- RLM (scaffold): CodeQA 26%, BrowseComp+ 2%, OOLONG 24%, OOLONG-Pairs 4.3%
- RLM fine-tuned (RLM-Qwen3-8B): CodeQA 32%, BrowseComp+ 14%, OOLONG 32%, OOLONG-Pairs 5.2%

Puntos a destacar:
1. Base Qwen3-8B sin scaffold: prácticamente inútil en todas las tareas — el modelo no sabe operar el REPL.
2. Solo con el scaffold RLM: mejora dramática en CodeQA (4→26%) y OOLONG (0→24%). El scaffold le enseña el mecanismo.
3. Con fine-tuning (RLM-Qwen3-8B): mejora adicional notable. El salto más espectacular es BrowseComp+: 2%→14% (7×).
4. OOLONG-Pairs: todos los valores son bajos porque esta tarea tiene complejidad O(N²). Qwen3-8B no tiene la potencia de GPT-5 para esta tarea cuadrática.

Media del paper: +28.3% vs base Qwen3-8B como RLM con el fine-tuning.
Coste inferencia de RLM-Qwen3-8B: comparable o menor al scaffold, por mejores decisiones desde el primer paso.
-->

---

<!-- _class: invert -->

<div style="display:flex; align-items:center; justify-content:space-between; height:100%; padding:0 20px;">

<div style="flex:1; padding-right:40px;">
  <div style="font-size:0.65em; color:#60a5fa; letter-spacing:0.12em; text-transform:uppercase; margin-bottom:8px;">From Theory to Practice</div>
  <div style="font-size:2em; font-weight:700; line-height:1.15; margin-bottom:18px;">Meet <span style="color:#60a5fa;">pyrlm-runtime</span></div>
  <div style="color:#94a3b8; font-size:0.9em; margin-bottom:28px;">v0.3.0 — Production-ready Python implementation of the MIT RLM paper. Algorithm 1, recursive subcalls, and everything you need to run RLMs at scale.</div>

  <div style="display:flex; flex-direction:column; gap:10px;">
    <div style="display:flex; align-items:center; gap:10px; background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:8px; padding:10px 14px;">
      <span style="color:#22c55e; font-size:1.1em;">✓</span>
      <span style="font-size:0.85em; color:#e2e8f0;">Implements <strong>Algorithm 1</strong> exactly as described in the paper</span>
    </div>
    <div style="display:flex; align-items:center; gap:10px; background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:8px; padding:10px 14px;">
      <span style="color:#22c55e; font-size:1.1em;">✓</span>
      <span style="font-size:0.85em; color:#e2e8f0;">Adapters: <strong>OpenAI · Azure OpenAI · VertexAI · Ollama · vLLM · Generic</strong></span>
    </div>
    <div style="display:flex; align-items:center; gap:10px; background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:8px; padding:10px 14px;">
      <span style="color:#22c55e; font-size:1.1em;">✓</span>
      <span style="font-size:0.85em; color:#e2e8f0;"><strong>Parallel subcalls</strong> · <strong>SmartRouter</strong> · <strong>Elasticsearch retrieval</strong> · <strong>Live trace</strong></span>
    </div>
    <div style="display:flex; align-items:center; gap:10px; background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:8px; padding:10px 14px;">
      <span style="color:#22c55e; font-size:1.1em;">✓</span>
      <span style="font-size:0.85em; color:#e2e8f0;"><strong>Monty REPL</strong> (Rust sandbox) · <strong>Conversation history</strong> · <strong>FileCache</strong></span>
    </div>
  </div>

  <div style="margin-top:22px; color:#64748b; font-size:0.78em;">github.com/apenab/pyrlm-runtime</div>
</div>

<div style="display:flex; flex-direction:column; align-items:center; gap:12px; min-width:200px;">
  <img src="images/qr-pyrlm.png" style="width:310px; height:310px; border-radius:12px; border:3px solid #60a5fa; padding:6px; background:white;" />
  <div style="font-size:0.72em; color:#60a5fa; text-align:center;">Scan to explore<br>the repo</div>
</div>

</div>

<!-- NOTAS — pyrlm-runtime v0.3.0: el estado actual
Esta slide es el pivote entre la teoría del paper del MIT y la implementación práctica.

Mencionar que en poco tiempo el proyecto ha evolucionado bastante: empezó como implementación mínima del paper y ahora tiene un ecosistema completo de producción.

Puntos clave:
- v0.3.0 es la versión disponible el día de la charla.
- Los adapters ahora cubren todos los grandes proveedores: cualquier API OpenAI-compatible, Azure, VertexAI (Google Cloud), Ollama/vLLM para local, y GenericChatAdapter para APIs custom con formato no estándar.
- Las features nuevas (parallel subcalls, SmartRouter, Elasticsearch, live trace) van más allá del paper original — son las cosas que hicieron falta al usarlo en proyectos reales.
- El QR lleva directamente al repo — invitar al público a explorarlo y contribuir.
- Las slides siguientes van componente por componente: arquitectura, SmartRouter, subcalls paralelas, retrieval, visualización en vivo.
-->

---

# 🏗️ rlm-runtime Architecture

<table style="width:100%; border-collapse:separate; border-spacing:0; background:rgba(30,58,95,0.4); border:2px solid #3b82f6; border-radius:14px; margin-top:4px;">
<tr><td colspan="5" style="padding:6px 14px; border:none; text-align:center;">
  <div style="background:rgba(234,179,8,0.15); border:2px solid #eab308; color:#fde68a; border-radius:10px; padding:6px 20px; font-weight:600; font-size:16px; display:inline-block;">📋 User Query + Context</div>
  <div style="font-size:18px; color:#94a3b8;">↓</div>
  <div style="background:rgba(96,165,250,0.15); border:2px solid #60a5fa; color:#93c5fd; border-radius:10px; padding:6px 20px; font-weight:600; font-size:16px; display:inline-block; margin-bottom:4px;">🔀 SmartRouter — baseline vs RLM auto-selection</div>
  <div style="font-size:18px; color:#94a3b8;">↓</div>
  <div style="background:rgba(34,197,94,0.15); border:2px solid #22c55e; color:#86efac; border-radius:10px; padding:8px; font-weight:600; font-size:18px;">🧠 RLM Orchestrator — Main loop · Conversation history · FINAL detection</div>
  <div style="font-size:18px; color:#94a3b8;">↓</div>
</td></tr>
<tr>
  <td style="border:none; padding:6px; width:20%; vertical-align:top;">
    <div style="background:rgba(239,68,68,0.15); border:2px solid #ef4444; color:#fca5a5; border-radius:10px; padding:8px; text-align:center; font-weight:600; font-size:14px;">⚙️ REPL<br><span style="font-size:12px; font-weight:400; color:#cbd5e1;">Python · Monty 🦀<br>peek · ask_chunks<br>llm_query · es_search</span></div>
  </td>
  <td style="border:none; padding:6px; width:20%; vertical-align:top;">
    <div style="background:rgba(59,130,246,0.15); border:2px solid #3b82f6; color:#93c5fd; border-radius:10px; padding:8px; text-align:center; font-weight:600; font-size:14px;">🔌 Adapters<br><span style="font-size:12px; font-weight:400; color:#cbd5e1;">OpenAI · Azure<br>VertexAI · Ollama<br>vLLM · Generic</span></div>
  </td>
  <td style="border:none; padding:6px; width:20%; vertical-align:top;">
    <div style="background:rgba(168,85,247,0.15); border:2px solid #a855f7; color:#d8b4fe; border-radius:10px; padding:8px; text-align:center; font-weight:600; font-size:14px;">🛡️ Policy<br><span style="font-size:12px; font-weight:400; color:#cbd5e1;">max_steps<br>max_tokens<br>max_subcalls</span></div>
  </td>
  <td style="border:none; padding:6px; width:20%; vertical-align:top;">
    <div style="background:rgba(234,179,8,0.15); border:2px solid #f59e0b; color:#fde68a; border-radius:10px; padding:8px; text-align:center; font-weight:600; font-size:14px;">📊 Trace + Cache<br><span style="font-size:12px; font-weight:400; color:#cbd5e1;">Full trace<br>FileCache<br>RichTraceListener</span></div>
  </td>
  <td style="border:none; padding:6px; width:20%; vertical-align:top;">
    <div style="background:rgba(16,185,129,0.15); border:2px solid #10b981; color:#6ee7b7; border-radius:10px; padding:8px; text-align:center; font-weight:600; font-size:14px;">🔍 Retriever<br><span style="font-size:12px; font-weight:400; color:#cbd5e1;">Elasticsearch<br>BM25 · kNN<br>Hybrid RRF</span></div>
  </td>
</tr>
<tr><td colspan="5" style="border:none; padding:4px 14px; text-align:center;">
  <div style="background:rgba(168,85,247,0.2); border:2px solid #a855f7; color:#d8b4fe; border-radius:10px; padding:6px; font-weight:600; font-size:15px; display:inline-block;">✅ Output: answer + full trace</div>
</td></tr>
</table>

<!--
NOTAS — rlm-runtime Architecture v0.3.0

Explicar el flujo completo de arriba abajo:

1. USER QUERY + CONTEXT entra al sistema.

2. SMARTROUTER: Primera decisión — ¿el contexto es pequeño (<8K chars)? Si sí, va directo al LLM como baseline (más rápido, menos tokens). Si no, activa el RLM completo. Ahorra tokens y latencia en casos simples automáticamente.

3. RLM ORCHESTRATOR (rlm.py): El corazón del sistema. Implementa el loop del paper: InitREPL → LLM genera código → REPL ejecuta → stdout vuelve al LLM → hasta FINAL. También gestiona conversation history multi-turn para autocorrección.

4. CINCO COMPONENTES:
   - REPL: PythonREPL (exec sandbox) o MontyREPL (Rust, secure by construction). Disponibles: peek(), ask_chunks(), llm_query() y ahora también es_search() si hay retriever.
   - Adapters: Abstracción para todos los proveedores. Ahora incluye VertexAI (Google Cloud) y GenericChatAdapter para APIs custom.
   - Policy: Límites de recursos. Thread-safe para subcalls paralelas.
   - Trace + Cache: Trace graba cada step. FileCache evita repetir subcalls idénticos. RichTraceListener visualiza en tiempo real.
   - Retriever: Conecta con Elasticsearch para corpora muy grandes sin cargar todo en memoria.

5. OUTPUT: respuesta + trace completo para debugging.
-->

---

# 💻 Minimal Example

```python
from pyrlm_runtime import RLM, Context
from pyrlm_runtime.adapters import OpenAICompatAdapter

# Load your long documents
documents = [
    "Document 1: Very long content...",
    "Document 2: More content...",
    # ... 100s of documents, millions of tokens
]
context = Context.from_documents(documents)

# Initialize RLM
adapter = OpenAICompatAdapter(model="gpt-4o")
rlm = RLM(
    adapter=adapter,
    conversation_history=True,   # LLM sees its own previous attempts
    repl_backend="monty",        # Rust sandbox (secure by default)
)

# Ask questions over the entire context
answer, trace = rlm.run("What is the key term defined in these documents?", context)

print(f"Answer: {answer}")
print(f"Steps: {len(trace.steps)}  |  Tokens: {trace.total_tokens}")
```

<!-- NOTAS — Minimal Example
Este es el patrón más básico. Tres pasos: cargar documentos, crear el RLM, hacer la pregunta.

Puntos a destacar:
- `Context.from_documents()` agrupa múltiples documentos con separadores. También existe `Context.from_text()` para un solo bloque.
- `conversation_history=True` es el default. Permite al LLM ver sus propias iteraciones anteriores y autocorregirse.
- `repl_backend="monty"` activa el sandbox en Rust. Lo explicamos en detalle en las slides de seguridad.
- El `trace` devuelve el historial completo: qué código generó el LLM en cada step, qué salió del REPL, cuántos tokens se usaron.
- El modelo `gpt-4o` es solo un ejemplo. Funciona con cualquier adapter: Azure, VertexAI, Ollama...
-->

---

# 🔀 SmartRouter: Baseline vs RLM

<div style="color:#94a3b8; font-size:0.88em; margin-bottom:14px;">Automatically selects the cheapest execution mode — no manual switching needed.</div>

<div style="display:flex; gap:14px; margin-bottom:14px;">
  <div style="flex:1; background:rgba(96,165,250,0.1); border:2px solid #60a5fa; border-radius:10px; padding:14px;">
    <div style="font-size:1em; font-weight:700; color:#93c5fd; margin-bottom:8px;">⚡ Short context <span style="color:#94a3b8; font-weight:400; font-size:0.85em;">(&lt; 8K chars)</span></div>
    <div style="font-size:0.82em; color:#94a3b8; line-height:1.6;">→ Direct LLM call<br>→ 1 API call, minimal tokens<br>→ Method: <code style="color:#60a5fa;">"baseline"</code></div>
  </div>
  <div style="flex:1; background:rgba(34,197,94,0.1); border:2px solid #22c55e; border-radius:10px; padding:14px;">
    <div style="font-size:1em; font-weight:700; color:#86efac; margin-bottom:8px;">🧠 Long context <span style="color:#94a3b8; font-weight:400; font-size:0.85em;">(≥ 8K chars)</span></div>
    <div style="font-size:0.82em; color:#94a3b8; line-height:1.6;">→ Full RLM loop<br>→ REPL + subcalls + trace<br>→ Method: <code style="color:#22c55e;">"rlm"</code></div>
  </div>
</div>

```python
from pyrlm_runtime import SmartRouter, RouterConfig, ExecutionProfile

router = SmartRouter(adapter, config=RouterConfig(baseline_threshold=8000))
result = router.run(query, context, profile=ExecutionProfile.DETERMINISTIC_FIRST)

print(f"Method: {result.method}")      # "baseline" or "rlm"
print(f"Tokens: {result.tokens_used}")
```

<div style="display:flex; gap:8px; margin-top:12px; flex-wrap:wrap;">
  <div style="background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:6px; padding:6px 10px; font-size:0.78em; color:#93c5fd;"><strong>DETERMINISTIC_FIRST</strong> — regex first, fallback to RLM</div>
  <div style="background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:6px; padding:6px 10px; font-size:0.78em; color:#93c5fd;"><strong>SEMANTIC_BATCHES</strong> — parallel subcalls</div>
  <div style="background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:6px; padding:6px 10px; font-size:0.78em; color:#93c5fd;"><strong>HYBRID</strong> — deterministic + semantic fallback</div>
  <div style="background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:6px; padding:6px 10px; font-size:0.78em; color:#93c5fd;"><strong>VERIFY</strong> — double-check with recursive subcalls</div>
</div>

<!-- NOTAS — SmartRouter
El SmartRouter es una capa de decisión inteligente por encima del RLM. Muchas veces el contexto no es tan grande y no hace falta todo el loop RLM — una llamada directa al LLM es suficiente y mucho más barata.

THRESHOLD: Por defecto 8000 chars. Si el contexto es menor, va directo al LLM. Si es mayor, activa el RLM completo. Este threshold es configurable vía RouterConfig.

EXECUTION PROFILES:
- DETERMINISTIC_FIRST: Intenta primero extracción determinista (regex, extract_after). Si no encuentra respuesta, cae al RLM. Cero tokens en el caso base. Ideal para extracción de campos.
- SEMANTIC_BATCHES: Usa subcalls en paralelo para clasificación semántica. Bueno para tareas de clasificación/filtrado.
- HYBRID: Combina determinista y semántico. El más robusto para producción.
- VERIFY: Usa recursive subcalls para double-check. El más preciso pero más lento.

RouterResult devuelve: output, trace, method, profile, context_chars, tokens_used, elapsed. Muy útil para logging y métricas.

Esto tiene sentido especialmente en pipelines donde tienes documentos de tamaño variable — pequeños van por baseline, grandes van por RLM.
-->

---

# ⚡ Parallel Subcalls: The Problem

<div style="color:#94a3b8; font-size:0.88em; margin-bottom:18px;">Subcalls are the bottleneck — sequential LLM calls stack up linearly.</div>

<div style="display:flex; gap:14px; align-items:center; margin-bottom:20px;">
  <div style="flex:1; background:rgba(239,68,68,0.1); border:2px solid #ef4444; border-radius:10px; padding:16px;">
    <div style="font-size:1em; font-weight:700; color:#fca5a5; margin-bottom:10px;">Sequential (default)</div>
    <div style="background:#0f172a; border-radius:6px; padding:10px; font-family:monospace; font-size:0.8em; color:#94a3b8; line-height:1.8;">
      subcall 1 ──→ wait 2s<br>
      subcall 2 ──→ wait 2s<br>
      subcall 3 ──→ wait 2s<br>
      <span style="color:#ef4444; font-weight:600;">Total: ~6s · 33 chunks = 66s</span>
    </div>
  </div>
  <div style="font-size:2em; color:#94a3b8;">→</div>
  <div style="flex:1; background:rgba(34,197,94,0.1); border:2px solid #22c55e; border-radius:10px; padding:16px;">
    <div style="font-size:1em; font-weight:700; color:#86efac; margin-bottom:10px;">Parallel (10 workers)</div>
    <div style="background:#0f172a; border-radius:6px; padding:10px; font-family:monospace; font-size:0.8em; color:#94a3b8; line-height:1.8;">
      subcall 1,2,3... ──→ wait 2s<br>
      subcall 11,12,13... ──→ wait 2s<br>
      subcall 21,22,23... ──→ wait 2s<br>
      <span style="color:#22c55e; font-weight:600;">Total: ~7s · same 33 chunks</span>
    </div>
  </div>
</div>

<div style="background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:10px; padding:12px; text-align:center !important; font-size:0.9em; color:#93c5fd;">
  Wait only for the <strong>slowest</strong> in the batch, not the <strong>sum</strong> of all
</div>

<!-- NOTAS — Parallel Subcalls: The Problem
Esta slide explica por qué el paralelismo importa.

EL PROBLEMA: En un loop RLM típico el LLM genera código que divide el contexto en N chunks y hace una subcall por chunk. Por ejemplo, 100 documentos → ~33 chunks de 3K chars. Si cada subcall tarda 2 segundos, el tiempo total es 66 segundos — inaceptable en producción.

LA SOLUCIÓN: Con ThreadPoolExecutor y 10 workers, enviamos 10 subcalls a la vez. Esperamos el tiempo del más lento del batch (~2s), no la suma. 33 chunks / 10 workers = 4 batches × 2s = ~8s. Una mejora de ~8x.

ANALOGÍA: Es como pedir 10 platos en un restaurante. Si el chef cocina de uno en uno tardas 10 veces más que si cocina todos a la vez.

La siguiente slide muestra cómo activarlo.
-->

---

# ⚡ Parallel Subcalls: 3 Ways to Enable

<div style="display:flex; gap:12px; margin-top:10px;">
  <div style="flex:1; background:rgba(96,165,250,0.08); border:1px solid #60a5fa; border-radius:10px; padding:14px;">
    <div style="font-size:0.95em; font-weight:700; color:#93c5fd; margin-bottom:8px;">1. <code>llm_batch()</code></div>
    <div style="font-size:0.8em; color:#94a3b8; line-height:1.5; margin-bottom:10px;">Always parallel. Auto-deduplication of identical prompts.</div>
    <div style="background:#0f172a; border-radius:6px; padding:10px; font-family:monospace; font-size:0.78em; color:#e2e8f0;">results = llm_batch([<br>  "Summarize doc 1",<br>  "Summarize doc 2",<br>  "Summarize doc 3",<br>])  # all 3 in parallel</div>
  </div>
  <div style="flex:1; background:rgba(96,165,250,0.08); border:1px solid #60a5fa; border-radius:10px; padding:14px;">
    <div style="font-size:0.95em; font-weight:700; color:#93c5fd; margin-bottom:8px;">2. <code>ask_chunks(parallel=True)</code></div>
    <div style="font-size:0.8em; color:#94a3b8; line-height:1.5; margin-bottom:10px;">Opt-in per call. Keeps sequential calls sequential.</div>
    <div style="background:#0f172a; border-radius:6px; padding:10px; font-family:monospace; font-size:0.78em; color:#e2e8f0;">answers = ask_chunks(<br>  "Find the date",<br>  ctx.chunk(3000),<br>  parallel=True,<br>)</div>
  </div>
  <div style="flex:1; background:rgba(96,165,250,0.08); border:1px solid #60a5fa; border-radius:10px; padding:14px;">
    <div style="font-size:0.95em; font-weight:700; color:#93c5fd; margin-bottom:8px;">3. Global flag</div>
    <div style="font-size:0.8em; color:#94a3b8; line-height:1.5; margin-bottom:10px;">All <code>ask_chunks</code> in the loop become parallel.</div>
    <div style="background:#0f172a; border-radius:6px; padding:10px; font-family:monospace; font-size:0.78em; color:#e2e8f0;">rlm = RLM(<br>  adapter=adapter,<br>  parallel_subcalls=True,<br>  max_concurrent_subcalls=10,<br>)</div>
  </div>
</div>

<div style="display:flex; gap:10px; margin-top:14px;">
  <div style="flex:1; background:rgba(34,197,94,0.08); border:1px solid rgba(34,197,94,0.3); border-radius:8px; padding:8px 12px; font-size:0.8em; color:#86efac;">✓ Thread-safe — Policy and Trace protected by locks</div>
  <div style="flex:1; background:rgba(34,197,94,0.08); border:1px solid rgba(34,197,94,0.3); border-radius:8px; padding:8px 12px; font-size:0.8em; color:#86efac;">✓ Auto-dedup — identical prompts sent only once</div>
</div>

<!-- NOTAS — Parallel Subcalls: 3 Ways to Enable
Tres opciones con diferente nivel de control:

1. llm_batch(): la más explícita. El LLM llama directamente a llm_batch() en el código que genera. Siempre paralelo. Internamente usa ThreadPoolExecutor con max_concurrent_subcalls workers (default 10). Deduplica: si envías el mismo prompt dos veces, solo hace una llamada al API.

2. ask_chunks(parallel=True): flag por llamada individual. Útil cuando quieres paralelizar solo algunas operaciones y mantener otras secuenciales (por ejemplo, primero una búsqueda secuencial, luego extracción paralela).

3. RLM(parallel_subcalls=True): flag global en la inicialización. A partir de aquí, TODOS los ask_chunks del loop son paralelos automáticamente. No hace falta cambiar el código del prompt.

THREAD SAFETY: Los contadores de Policy (max_subcalls, max_tokens) usan threading.Lock. El Trace usa locks para mutaciones concurrentes. El step_id counter es atómico. Se puede paralelizar sin preocuparte por race conditions.

CONSEJO: Para producción, el flag global es el más cómodo. Para debugging o reproducibilidad determinista, conviene dejarlo en False.
-->

---

# 🔍 External Retrieval: Architecture

<div style="color:#94a3b8; font-size:0.88em; margin-bottom:12px;">Normal RLM loads all docs into memory. External Retrieval lets the LLM <strong style="color:#e2e8f0;">pull documents on demand</strong> from any index.</div>

<div style="display:flex; gap:10px; align-items:center; justify-content:center; margin:18px 0 22px;">
  <div style="background:rgba(234,179,8,0.12); border:2px solid #eab308; border-radius:10px; padding:10px 18px; text-align:center; font-size:0.85em; color:#fde68a; font-weight:600;">User Query</div>
  <div style="color:#94a3b8;">→</div>
  <div style="background:rgba(34,197,94,0.12); border:2px solid #22c55e; border-radius:10px; padding:10px 18px; text-align:center; font-size:0.85em; color:#86efac; font-weight:600;">RLM Orchestrator</div>
  <div style="color:#94a3b8;">→</div>
  <div style="background:rgba(239,68,68,0.12); border:2px solid #ef4444; border-radius:10px; padding:10px 18px; text-align:center; font-size:0.85em; color:#fca5a5; font-weight:600;">REPL<br><span style="font-weight:400; font-size:0.85em;">es_search · es_get</span></div>
  <div style="color:#94a3b8;">→</div>
  <div style="background:rgba(16,185,129,0.12); border:2px solid #10b981; border-radius:10px; padding:10px 18px; text-align:center; font-size:0.85em; color:#6ee7b7; font-weight:600;">Retriever<br><span style="font-weight:400; font-size:0.85em;">ES · Qdrant · custom</span></div>
  <div style="color:#94a3b8;">↺</div>
</div>

<div style="display:flex; gap:12px;">
  <div style="flex:1; background:rgba(16,185,129,0.08); border:1px solid rgba(16,185,129,0.4); border-radius:10px; padding:14px;">
    <div style="font-size:0.85em; font-weight:700; color:#6ee7b7; margin-bottom:10px;">RetrieverProtocol — 4 methods</div>
    <div style="font-size:0.8em; color:#94a3b8; line-height:1.9;">
      <code style="color:#6ee7b7;">search(query)</code> &nbsp;&nbsp;&nbsp; BM25 keyword<br>
      <code style="color:#6ee7b7;">vector_search(query)</code> &nbsp; kNN semantic<br>
      <code style="color:#6ee7b7;">hybrid_search(query)</code> &nbsp; BM25 + kNN (RRF)<br>
      <code style="color:#6ee7b7;">get(doc_id)</code> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; full document
    </div>
  </div>
  <div style="flex:1; background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:10px; padding:14px;">
    <div style="font-size:0.85em; font-weight:700; color:#93c5fd; margin-bottom:10px;">vs Normal RLM</div>
    <div style="font-size:0.8em; color:#94a3b8; line-height:1.9;">
      <span style="color:#ef4444;">✗</span> &nbsp;All docs loaded into RAM upfront<br>
      <span style="color:#22c55e;">✓</span> &nbsp;Docs fetched on-demand from index<br>
      <span style="color:#22c55e;">✓</span> &nbsp;No <code>context</code> needed in <code>rlm.run()</code><br>
      <span style="color:#22c55e;">✓</span> &nbsp;Scales to millions of documents
    </div>
  </div>
</div>

<!-- NOTAS — External Retrieval: Architecture
Esta slide explica la arquitectura conceptual antes de entrar en la implementación concreta con Elasticsearch.

PROBLEMA: El approach RLM del paper asume que todo el contexto está disponible como string en memoria. Funciona bien hasta ~500K documentos razonables. Pero ¿qué pasa con un corpus legal de 10 millones de contratos o una base de conocimiento corporativa?

LA SOLUCIÓN: En lugar de cargar todo en P, el LLM puede hacer búsquedas directamente desde el REPL. Las funciones de búsqueda se inyectan en el REPL igual que peek(), llm_query() o ask_chunks(). Para el LLM, llamar a es_hybrid_search() es exactamente igual que llamar a cualquier otra función Python.

FLUJO DEL LOOP:
1. La query llega al RLM. No hace falta context.
2. El system prompt se extiende automáticamente con guía sobre cómo usar las funciones de búsqueda.
3. LLM genera código que llama es_hybrid_search("lo que busca").
4. El REPL ejecuta esa llamada, que va al backend (Elasticsearch, Qdrant...).
5. Los resultados vuelven como stdout al LLM.
6. El LLM puede hacer más búsquedas, ir a documentos específicos con es_get(), razonar sobre los resultados.
7. FINAL cuando tiene la respuesta.

RETRIEVERPROTOCOL: Interfaz agnóstica. Cualquier backend que implemente estos 4 métodos funciona como drop-in. Elasticsearch ya viene implementado. Para Qdrant, Pinecone o un sistema propio, solo hay que implementar los 4 métodos.

CLAVE ARQUITECTURAL: El retrieval no es un pipeline separado ni una herramienta especial. Es simplemente código Python en el REPL. Esto lo hace composable: el LLM puede combinar búsquedas, filtrar resultados, paginar, etc. exactamente igual que haría con cualquier código Python.
-->

---

# 🔍 External Retrieval: Elasticsearch

<div style="color:#94a3b8; font-size:0.88em; margin-bottom:14px;">Built-in implementation of <code>RetrieverProtocol</code> — BM25, semantic and hybrid search out of the box.</div>

<div style="display:flex; gap:14px; align-items:flex-start;">
  <div style="flex:1;">

```python
from pyrlm_runtime import RLM
from pyrlm_runtime.retrieval import ElasticsearchRetriever

retriever = ElasticsearchRetriever(
    host="https://my-cluster.es.cloud.com",
    api_key="xxx",
    index="legal_docs",
    vector_field="embedding",
    embedding_model="text-embedding-3-small",
)

# No context needed — retriever provides docs on demand
rlm = RLM(adapter=adapter, retriever=retriever)
answer, trace = rlm.run("Who signed the NDA on March 2024?")
```

  </div>
  <div style="flex:0 0 220px; display:flex; flex-direction:column; gap:8px;">
    <div style="background:rgba(16,185,129,0.1); border:1px solid #10b981; border-radius:8px; padding:10px;">
      <div style="font-size:0.8em; font-weight:700; color:#6ee7b7; margin-bottom:6px;">REPL functions:</div>
      <div style="font-size:0.75em; color:#94a3b8; line-height:1.7;"><code>es_search(q)</code> — BM25<br><code>es_vector_search(q)</code> — kNN<br><code>es_hybrid_search(q)</code> — RRF<br><code>es_get(doc_id)</code> — full doc</div>
    </div>
    <div style="background:rgba(16,185,129,0.1); border:1px solid #10b981; border-radius:8px; padding:10px;">
      <div style="font-size:0.8em; font-weight:700; color:#6ee7b7; margin-bottom:6px;">All support:</div>
      <div style="font-size:0.75em; color:#94a3b8; line-height:1.7;"><code>top_k=10</code><br><code>filters={"field": "val"}</code><br>Lazy import (optional dep)</div>
    </div>
  </div>
</div>

<!-- NOTAS — External Retrieval: Elasticsearch
Esta slide es la implementación concreta después de haber explicado la arquitectura.

ELASTICSEARCHRETRIEVER es la implementación incluida de RetrieverProtocol. Parámetros principales:
- host + api_key: conexión al cluster
- index: el índice donde están los documentos
- content_field (default "content"): el campo con el texto del documento
- vector_field + embedding_model: necesarios para vector_search y hybrid_search
- preview_length: cuántos chars devuelve en los previews (default 500)
- embedding_base_url: por defecto usa OpenAI, pero puede ser cualquier API compatible

LAS FUNCIONES EN EL REPL:
- es_search(): BM25 keyword. El LLM lo usa para búsquedas de términos exactos (nombres propios, números de contrato, fechas exactas).
- es_vector_search(): kNN sobre dense_vector. Bueno cuando el LLM busca semánticamente ("cláusulas de confidencialidad").
- es_hybrid_search(): Reciprocal Rank Fusion de BM25 + kNN. El más robusto para uso general.
- es_get(doc_id): Fetch del documento completo. El LLM primero hace una búsqueda para encontrar IDs, luego va a buscar el documento entero si necesita más contexto.

FILTERS: Todos los métodos aceptan filters dict para filtrar por metadatos. Ejemplo: {"date_after": "2024-01-01"} o {"department": "legal"}.

LAZY IMPORT: Elasticsearch como dependencia opcional. Si no usas retrieval, no necesitas instalarlo.

CASO REAL: "Who signed the NDA on March 2024?" — el LLM probablemente hace es_hybrid_search("NDA signed March 2024"), ve los previews, hace es_get() sobre el más prometedor, extrae el firmante del texto completo.
-->

---

# 📡 Live Trace Visualization

<div style="display:flex; gap:16px; align-items:flex-start; margin-top:10px;">

<div style="flex:0 0 300px;">

```python
from pyrlm_runtime.rich_trace import (
    RichTraceListener,
)

rlm = RLM(
    adapter=adapter,
    event_listener=RichTraceListener(),
)
answer, trace = rlm.run(query, context)
```

  <div style="display:flex; flex-direction:column; gap:6px; margin-top:4px;">
    <div style="background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:7px; padding:7px 10px; font-size:0.76em; color:#93c5fd;">Root Call → cyan panel + code</div>
    <div style="background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:7px; padding:7px 10px; font-size:0.76em; color:#93c5fd;">In [N] / Out [N] → blue/green panels</div>
    <div style="background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:7px; padding:7px 10px; font-size:0.76em; color:#93c5fd;">Parallel Subcalls → magenta panels</div>
    <div style="background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:7px; padding:7px 10px; font-size:0.76em; color:#93c5fd;">Errors → red panel + traceback</div>
  </div>
</div>

<div style="flex:1; background:#0a0a0a; border-radius:10px; padding:14px; font-family:monospace; font-size:0.7em; line-height:1.6; text-align:left; color:#e2e8f0;">
<span style="color:#22d3ee;">──────────────── RLM Run ────────────────</span><br>
<span style="color:#22d3ee;">╭────────────────────────────────────────╮</span><br>
<span style="color:#22d3ee;">│</span> Query: Find the date in these docs <span style="color:#22d3ee;">&nbsp;&nbsp;&nbsp;&nbsp;│</span><br>
<span style="color:#22d3ee;">│</span> REPL backend: monty &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#22d3ee;">│</span><br>
<span style="color:#22d3ee;">╰────────────────────────────────────────╯</span><br>
<span style="color:#22d3ee;">╭─ Root Call ──────── step=1 tokens=312 ─╮</span><br>
<span style="color:#22d3ee;">│</span> <span style="color:#e2e8f0;">chunks = ctx.chunk(3000)</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#22d3ee;">│</span><br>
<span style="color:#22d3ee;">│</span> <span style="color:#e2e8f0;">answers = ask_chunks("date?", chunks)</span>&nbsp;&nbsp;<span style="color:#22d3ee;">│</span><br>
<span style="color:#22d3ee;">╰────────────────────────────────────────╯</span><br>
<span style="color:#c084fc;">──────── Parallel Subcalls (8) ──────────</span><br>
<span style="color:#c084fc;">╭─ Parallel Subcall [3/8] ── cached ─────╮</span><br>
<span style="color:#c084fc;">│</span> Output: <span style="color:#22c55e;">March 15, 2024</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#c084fc;">│</span><br>
<span style="color:#c084fc;">╰────────────────────────────────────────╯</span><br>
<span style="color:#3b82f6;">╭─ In [1] ───────────────────────────────╮</span><br>
<span style="color:#3b82f6;">│</span> <span style="color:#e2e8f0;">&nbsp;1 answer = pick_first_answer(answers)</span>&nbsp;<span style="color:#3b82f6;">│</span><br>
<span style="color:#22c55e;">╭─ Out [1] ──────────────────────────────╮</span><br>
<span style="color:#22c55e;">│</span> March 15, 2024 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#22c55e;">│</span><br>
<span style="color:#22c55e;">╰────────────────────────────────────────╯</span>
</div>

</div>

<!-- NOTAS — Live Trace Visualization
Esta feature hace que el proceso RLM sea completamente transparente en tiempo real. Antes solo podías inspeccionar el trace después de que terminara. Ahora puedes ver cada step mientras ocurre.

IMPLEMENTACIÓN: RichTraceListener implementa el protocolo RLMEventListener. Cada vez que el RLM genera un event (step start, repl exec, subcall, final), el listener lo renderiza en el terminal via Rich.

LO QUE SE VE:
- Step number y tipo (root_call, repl_exec, subcall, recursive_subcall)
- El código generado por el LLM
- El stdout del REPL
- Para subcalls: indicador de si fueron paralelas, cuántas, qué respuesta dio cada una
- Cache hits en verde
- Errores en rojo con traceback
- Token count por step y total
- Tiempo de cada step

THREAD SAFETY: El listener usa locks internos para que los renders de subcalls paralelas no se mezclen en el output.

USO: Imprescindible durante desarrollo y debugging. En producción se puede desactivar simplemente no pasando event_listener=.

Para demos en vivo: esta visualización hace que sea muy fácil ver lo que está haciendo el RLM — perfecto para mostrar en la charla.
-->

---

# 🔒 The Security Question

An RLM executes **LLM-generated code** in a Python REPL. What could go wrong?

<div style="display:flex; gap:12px; margin-top:14px;">
  <div style="flex:1; background:rgba(239,68,68,0.12); border:2px solid #ef4444; border-radius:10px; padding:14px;">
    <div style="font-size:1.1em; font-weight:700; color:#fca5a5; margin-bottom:6px;">⚠️ Current: <code style="background:transparent; color:#fca5a5;">exec()</code> sandbox</div>
    <div style="font-size:0.85em; color:#94a3b8; line-height:1.6;">
      Whitelist-based blocking<br>
      Bypasseable via <code style="background:rgba(255,255,255,0.08);">__builtins__</code><br>
      Infinite loops <strong style="color:#ef4444;">hang the process</strong><br>
      Memory bombs <strong style="color:#ef4444;">crash the host</strong>
    </div>
  </div>
  <div style="flex:1; background:rgba(34,197,94,0.12); border:2px solid #22c55e; border-radius:10px; padding:14px;">
    <div style="font-size:1.1em; font-weight:700; color:#86efac; margin-bottom:6px;">✅ New: Pydantic Monty</div>
    <div style="font-size:0.85em; color:#94a3b8; line-height:1.6;">
      Minimal Python interpreter <strong style="color:#86efac;">in Rust</strong><br>
      No <code style="background:rgba(255,255,255,0.08);">exec()</code>, no imports, no introspection<br>
      Timeout: <strong style="color:#86efac;">5s default</strong> (configurable)<br>
      Memory limit: <strong style="color:#86efac;">128MB default</strong>
    </div>
  </div>
</div>

<div style="background:rgba(96,165,250,0.1); border:1px solid #60a5fa; border-radius:10px; padding:10px; margin-top:14px; text-align:center !important; font-size:0.95em;">
  🦀 <strong>pydantic-monty</strong> — by the Pydantic team · designed for LLM code execution
</div>

<!--
NOTAS — The Security Question

CONTEXTO: Este es un problema fundamental del approach RLM. Estamos dándole a un LLM la capacidad de ejecutar código arbitrario en un Python REPL. Incluso con un LLM "bueno" (GPT-5, Claude), hay riesgos:
- Prompt injection: un documento malicioso podría engañar al LLM para que ejecute código peligroso.
- Errores del modelo: el LLM podría generar accidentalmente un `while True: pass` o un `[0]*10**9`.
- Sandbox escapes: `exec()` en CPython es notoriamente difícil de sandboxear. Hay exploits conocidos via `__builtins__.__import__('os')`, introspection con `__class__.__bases__`, etc.

LA SOLUCIÓN: Pydantic Monty (https://github.com/pydantic/monty) es un intérprete Python mínimo escrito en Rust. No es CPython — es un intérprete nuevo que solo implementa un subconjunto seguro de Python. No tiene `exec()`, no tiene `eval()`, no tiene imports, no tiene acceso al MRO de Python. Es "secure by construction", no por whitelist.

LÍMITES CONFIGURABLES: timeout (5s default), memoria (128MB), allocations (1M), stack depth (100). Si el código excede cualquier límite, Monty lo mata limpiamente.

TRANSICIÓN: "Veamos el impacto concreto en seguridad..."
-->

---

# 🛡️ Security: Before vs After

<div style="display:flex; flex-direction:column; gap:7px; margin-top:10px;">

  <div style="display:flex; gap:10px;">
    <div style="flex:2.2; font-size:0.75em; color:#64748b; padding:0 10px;">Threat</div>
    <div style="flex:1; font-size:0.75em; color:#64748b; text-align:center;">PythonREPL</div>
    <div style="flex:1; font-size:0.75em; color:#64748b; text-align:center;">MontyREPL 🦀</div>
  </div>

  <div style="display:flex; gap:10px; align-items:center;">
    <div style="flex:2.2; background:rgba(255,255,255,0.04); border-radius:8px; padding:8px 12px; font-size:0.82em; color:#e2e8f0;">Sandbox escape via <code>__builtins__</code></div>
    <div style="flex:1; background:rgba(239,68,68,0.15); border:1px solid #ef4444; border-radius:8px; padding:8px; text-align:center; font-size:0.8em; font-weight:700; color:#fca5a5;">VULNERABLE</div>
    <div style="flex:1; background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:8px; padding:8px; text-align:center; font-size:0.8em; font-weight:700; color:#86efac;">BLOCKED</div>
  </div>

  <div style="display:flex; gap:10px; align-items:center;">
    <div style="flex:2.2; background:rgba(255,255,255,0.04); border-radius:8px; padding:8px 12px; font-size:0.82em; color:#e2e8f0;">Nested <code>exec()</code> / <code>eval()</code></div>
    <div style="flex:1; background:rgba(239,68,68,0.15); border:1px solid #ef4444; border-radius:8px; padding:8px; text-align:center; font-size:0.8em; font-weight:700; color:#fca5a5;">VULNERABLE</div>
    <div style="flex:1; background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:8px; padding:8px; text-align:center; font-size:0.8em; font-weight:700; color:#86efac;">BLOCKED</div>
  </div>

  <div style="display:flex; gap:10px; align-items:center;">
    <div style="flex:2.2; background:rgba(255,255,255,0.04); border-radius:8px; padding:8px 12px; font-size:0.82em; color:#e2e8f0;">Introspection <code>__class__.__bases__</code></div>
    <div style="flex:1; background:rgba(239,68,68,0.15); border:1px solid #ef4444; border-radius:8px; padding:8px; text-align:center; font-size:0.8em; font-weight:700; color:#fca5a5;">VULNERABLE</div>
    <div style="flex:1; background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:8px; padding:8px; text-align:center; font-size:0.8em; font-weight:700; color:#86efac;">BLOCKED</div>
  </div>

  <div style="display:flex; gap:10px; align-items:center;">
    <div style="flex:2.2; background:rgba(255,255,255,0.04); border-radius:8px; padding:8px 12px; font-size:0.82em; color:#e2e8f0;">Infinite loop <code>while True: pass</code></div>
    <div style="flex:1; background:rgba(239,68,68,0.15); border:1px solid #ef4444; border-radius:8px; padding:8px; text-align:center; font-size:0.8em; font-weight:700; color:#fca5a5;">HANGS</div>
    <div style="flex:1; background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:8px; padding:8px; text-align:center; font-size:0.8em; font-weight:700; color:#86efac;">TIMEOUT 5s</div>
  </div>

  <div style="display:flex; gap:10px; align-items:center;">
    <div style="flex:2.2; background:rgba(255,255,255,0.04); border-radius:8px; padding:8px 12px; font-size:0.82em; color:#e2e8f0;">Memory bomb <code>[0]*10**9</code></div>
    <div style="flex:1; background:rgba(239,68,68,0.15); border:1px solid #ef4444; border-radius:8px; padding:8px; text-align:center; font-size:0.8em; font-weight:700; color:#fca5a5;">CRASH</div>
    <div style="flex:1; background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:8px; padding:8px; text-align:center; font-size:0.8em; font-weight:700; color:#86efac;">LIMIT 128MB</div>
  </div>

  <div style="display:flex; gap:10px; align-items:center;">
    <div style="flex:2.2; background:rgba(255,255,255,0.04); border-radius:8px; padding:8px 12px; font-size:0.82em; color:#e2e8f0;">Import <code>os</code> / <code>sys</code></div>
    <div style="flex:1; background:rgba(234,179,8,0.12); border:1px solid #eab308; border-radius:8px; padding:8px; text-align:center; font-size:0.8em; font-weight:700; color:#fde68a;">BYPASSEABLE</div>
    <div style="flex:1; background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:8px; padding:8px; text-align:center; font-size:0.8em; font-weight:700; color:#86efac;">NO IMPORTS</div>
  </div>

</div>

<div style="background:rgba(34,197,94,0.1); border:1px solid #22c55e; border-radius:10px; padding:9px; margin-top:10px; text-align:center !important; font-size:0.9em;">
  🔑 <strong>Secure by construction</strong> — not by blacklist
</div>

<!--
NOTAS — Security: Before vs After

RECORRER LA TABLA fila por fila:

1. Sandbox escape: En CPython, puedes hacer `().__class__.__bases__[0].__subclasses__()` para acceder a todas las clases cargadas, y desde ahí importar `os` o `subprocess`. En Monty no existe el MRO de CPython — es un intérprete diferente.

2. Nested exec/eval: En CPython, dentro de un `exec()` puedes llamar a otro `exec()`. Esto permite construir payloads dinámicos que evitan detección estática. Monty simplemente no implementa `exec()` ni `eval()`.

3. Introspection: `__class__.__bases__` y `__subclasses__()` son las técnicas clásicas de Python jail escape. Monty no tiene acceso a estas dunder methods.

4. Infinite loop: Un `while True: pass` en CPython con `exec()` cuelga el proceso indefinidamente (a menos que uses `multiprocessing` con timeout, que tiene sus propios problemas). Monty tiene un timeout configurable que mata la ejecución limpiamente.

5. Memory bomb: `[0] * (10**9)` asigna ~8GB de RAM instantáneamente en CPython. Monty tiene un límite de memoria (128MB default) y un límite de allocations (1M).

6. Imports: En CPython, la whitelist puede ser bypaseada por los escapes anteriores. En Monty, el concepto de "import" no existe.

PUNTO CLAVE: "No es que Monty bloquee estos ataques — es que ni siquiera tiene los mecanismos que los hacen posibles. Es como preguntarle a una calculadora que hackee un servidor."
-->

---

# ⚡ Monty: Performance Impact

<div class="columns">
<div>

**Isolated REPL** (micro-benchmark):

<div style="display:flex; flex-direction:column; gap:8px; margin-top:10px;">
  <div style="background:rgba(234,179,8,0.12); border:1px solid #eab308; border-radius:10px; padding:10px;">
    <div style="font-size:0.95em; color:#fde68a; font-weight:600;">Monty is ~3-4x slower</div>
    <div style="font-size:0.8em; color:#94a3b8;">Simple exec: 3ms vs 1ms</div>
  </div>
  <div style="background:rgba(234,179,8,0.12); border:1px solid #eab308; border-radius:10px; padding:10px;">
    <div style="font-size:0.95em; color:#fde68a; font-weight:600;">But all times are 1-25ms</div>
    <div style="font-size:0.8em; color:#94a3b8;">Even worst case: 25ms</div>
  </div>
</div>

</div>
<div>

**Full RLM loop** (production):

<div style="display:flex; flex-direction:column; gap:8px; margin-top:10px;">
  <div style="background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:10px; padding:10px;">
    <div style="font-size:0.95em; color:#86efac; font-weight:600;">Only ~1.6x slower</div>
    <div style="font-size:0.8em; color:#94a3b8;">Overhead: +0.07ms per execution</div>
  </div>
  <div style="background:rgba(34,197,94,0.12); border:1px solid #22c55e; border-radius:10px; padding:10px;">
    <div style="font-size:0.95em; color:#86efac; font-weight:600;">REPL is &lt;0.01% of total time</div>
    <div style="font-size:0.8em; color:#94a3b8;">LLM calls dominate: 100-5000ms each</div>
  </div>
</div>

</div>
</div>

<div style="background:#0f172a; border-radius:8px; padding:12px; margin-top:14px; font-family:monospace; font-size:0.8em; color:#94a3b8; text-align:center !important;">
<span style="color:#ef4444;">|── LLM call (500ms) ──|</span><span style="color:#22c55e;">|REPL|</span><span style="color:#ef4444;">|── LLM call (500ms) ──|</span><br>
<span style="font-size:0.85em; color:#64748b;">The cost of security is practically zero</span>
</div>

<!--
NOTAS — Monty: Performance Impact

Este slide es el PUNCHLINE de la sección de seguridad. La preocupación obvia es: "si Monty es un intérprete diferente, ¿no será más lento?" La respuesta es: sí, pero no importa.

MICRO-BENCHMARK (REPL aislado, sin LLM):
- Monty es ~3-4x más lento que CPython en ejecución cruda: 3ms vs 1ms para operaciones simples, hasta 25ms para multi-step.
- Esto suena mal en aislamiento (3-4x!), pero los tiempos absolutos son milisegundos.

LOOP RLM COMPLETO (con FakeAdapter):
- Cuando mides el loop RLM completo, Monty solo es ~1.6x más lento. ¿Por qué? Porque el REPL es una fracción mínima del tiempo total.
- Overhead promedio: +0.07ms por ejecución.

EN PRODUCCIÓN REAL:
- Una llamada al LLM toma entre 100ms y 5000ms (según modelo y tokens).
- El REPL toma 0.2ms.
- Proporción: 0.2ms / 1000ms = 0.02% del tiempo total.
- El diagrama de tiempos lo muestra visualmente: las barras rojas (LLM) dominan, la barra verde (REPL) es casi invisible.

MENSAJE CLAVE: "La integración de Monty elimina TODAS las vulnerabilidades de seguridad conocidas del REPL, a un costo de rendimiento de +0.07ms por ejecución — menos del 0.01% del tiempo total de un ciclo RLM en producción."

BENCHMARK COMMANDS (para referencia):
- REPL aislado: `uv run python examples/bench_repl_python_vs_monty.py`
- Loop completo: `uv run python examples/bench_rlm_repl_backends.py`
- Exportar: `RLM_EXPORT=1` prefijo
-->

---

# 🎯 Real Use Cases

<div style="display:flex; gap:12px; margin-top:10px;">
  <div style="flex:1; background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:10px; padding:14px;">
    <div style="font-size:1em; font-weight:700; color:#93c5fd; margin-bottom:6px;">1. Code Repository</div>
    <div style="font-size:0.8em; color:#94a3b8; line-height:1.5;">Analyze entire codebases (900K+ tokens). Find implementations across files. Understand architectural decisions.</div>
  </div>
  <div style="flex:1; background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:10px; padding:14px;">
    <div style="font-size:1em; font-weight:700; color:#93c5fd; margin-bottom:6px;">2. Deep Research</div>
    <div style="font-size:0.8em; color:#94a3b8; line-height:1.5;">Process 100s of academic papers. Multi-hop reasoning across documents. Evidence synthesis.</div>
  </div>
</div>
<div style="display:flex; gap:12px; margin-top:12px;">
  <div style="flex:1; background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:10px; padding:14px;">
    <div style="font-size:1em; font-weight:700; color:#93c5fd; margin-bottom:6px;">3. Document Analysis</div>
    <div style="font-size:0.8em; color:#94a3b8; line-height:1.5;">Legal contract review (100+ page contracts). Medical records analysis. Technical documentation.</div>
  </div>
  <div style="flex:1; background:rgba(16,185,129,0.1); border:1px solid #10b981; border-radius:10px; padding:14px;">
    <div style="font-size:1em; font-weight:700; color:#6ee7b7; margin-bottom:6px;">4. Large Corpus Retrieval</div>
    <div style="font-size:0.8em; color:#94a3b8; line-height:1.5;">Millions of docs in Elasticsearch. RLM directs its own retrieval strategy. No full-corpus loading needed.</div>
  </div>
</div>

<!-- NOTAS — Real Use Cases
Estos son casos reales donde el approach RLM tiene sentido. Recorrerlos brevemente:

1. CODE REPO: Un repo grande como CPython tiene ~900K tokens. Imposible de meter en un context window. El RLM puede explorar el repo sistemáticamente: primero mira el índice de archivos, luego va a los más relevantes, luego hace subcalls para analizar cada función.

2. DEEP RESEARCH: Imagina que tienes 200 papers sobre un tema. El RLM puede leer el abstract de cada uno, identificar los más relevantes, y luego leer esos en profundidad. Con subcalls paralelas esto es muy rápido.

3. DOCUMENT ANALYSIS: Contratos legales de 100+ páginas. El LLM no puede leer 100 páginas de una vez. Pero el RLM puede ir sección por sección, extraer las cláusulas relevantes, y construir un resumen estructurado.

4. LARGE CORPUS RETRIEVAL (NUEVO): Con la integración de Elasticsearch, el RLM puede trabajar sobre millones de documentos. El LLM decide qué buscar, cómo buscar (keyword vs semantic), y cuándo tiene suficiente información para responder. Es RAG + RLM combinados.
-->

---

# When to Use RLM?

<div style="display:flex; gap:16px; margin-top:14px;">
  <div style="flex:1;">
    <div style="font-size:0.88em; font-weight:700; color:#86efac; margin-bottom:12px; text-align:center;">✅ Use when...</div>
    <div style="display:flex; flex-direction:column; gap:8px;">
      <div style="background:rgba(34,197,94,0.1); border:1px solid #22c55e; border-radius:8px; padding:9px 14px; font-size:0.82em; color:#86efac;">Context &gt; 50K tokens</div>
      <div style="background:rgba(34,197,94,0.1); border:1px solid #22c55e; border-radius:8px; padding:9px 14px; font-size:0.82em; color:#86efac;">Info scattered across entire input</div>
      <div style="background:rgba(34,197,94,0.1); border:1px solid #22c55e; border-radius:8px; padding:9px 14px; font-size:0.82em; color:#86efac;">Need to examine most/all content</div>
      <div style="background:rgba(34,197,94,0.1); border:1px solid #22c55e; border-radius:8px; padding:9px 14px; font-size:0.82em; color:#86efac;">Accuracy over speed</div>
      <div style="background:rgba(34,197,94,0.1); border:1px solid #22c55e; border-radius:8px; padding:9px 14px; font-size:0.82em; color:#86efac;">Cost-sensitive vs frontier models</div>
    </div>
  </div>
  <div style="flex:1;">
    <div style="font-size:0.88em; font-weight:700; color:#fca5a5; margin-bottom:12px; text-align:center;">❌ Don't use when...</div>
    <div style="display:flex; flex-direction:column; gap:8px;">
      <div style="background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:8px; padding:9px 14px; font-size:0.82em; color:#fca5a5;">Context fits in window (&lt;50K tokens)</div>
      <div style="background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:8px; padding:9px 14px; font-size:0.82em; color:#fca5a5;">Simple search would work</div>
      <div style="background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:8px; padding:9px 14px; font-size:0.82em; color:#fca5a5;">Info is localized (RAG is faster)</div>
      <div style="background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:8px; padding:9px 14px; font-size:0.82em; color:#fca5a5;">Real-time response needed</div>
      <div style="background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:8px; padding:9px 14px; font-size:0.82em; color:#fca5a5;">Task is trivial</div>
    </div>
  </div>
</div>

<div style="background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:8px; padding:10px; margin-top:14px; text-align:center !important; font-size:0.85em; color:#93c5fd;">
  Rule of thumb: <strong>if baseline truncates or fails → try RLM</strong>
</div>

<!-- NOTAS — When NOT to Use RLM
La segunda parte del slide. Ahora mostramos ambas columnas.

CUÁNDO NO:
- Context fits in window: Si tienes <50K tokens, un baseline directo es más rápido y barato. El SmartRouter hace esto automáticamente.
- Simple search: Para preguntas tipo "¿cuál es el valor del campo X en este JSON?" no necesitas un loop iterativo. Un regex o extract_after() es suficiente.
- Info localized: Si sabes que la respuesta está en una sección concreta, RAG (BM25 + LLM) es más eficiente que un RLM completo.
- Real-time: El loop RLM tarda entre 10s y 2 minutos según la complejidad. No es adecuado para respuestas en tiempo real.
- Trivial: Extraer un campo de un formulario de 2 páginas no merece un RLM.

RULE OF THUMB: "Si el baseline falla o trunca, prueba RLM." Es la decisión más simple posible. El SmartRouter implementa esto automáticamente con el threshold configurable.
-->

---

# 🚀 Roadmap

<div style="display:flex; gap:14px; margin-top:12px;">
  <div style="flex:1; background:rgba(34,197,94,0.08); border:1px solid rgba(34,197,94,0.3); border-radius:10px; padding:14px;">
    <div style="font-size:0.95em; font-weight:700; color:#86efac; margin-bottom:10px;">✅ Delivered (v0.3.0)</div>
    <div style="display:flex; flex-direction:column; gap:6px;">
      <div style="font-size:0.78em; color:#94a3b8;">✓ MontyREPL — Rust sandbox</div>
      <div style="font-size:0.78em; color:#94a3b8;">✓ Parallel subcalls — llm_batch + ThreadPoolExecutor</div>
      <div style="font-size:0.78em; color:#94a3b8;">✓ Conversation history — multi-turn self-correction</div>
      <div style="font-size:0.78em; color:#94a3b8;">✓ Elasticsearch retrieval — BM25 + kNN + hybrid</div>
      <div style="font-size:0.78em; color:#94a3b8;">✓ VertexAI adapter — Google Cloud support</div>
      <div style="font-size:0.78em; color:#94a3b8;">✓ Live trace — RichTraceListener</div>
      <div style="font-size:0.78em; color:#94a3b8;">✓ SmartRouter — auto baseline vs RLM</div>
    </div>
  </div>
  <div style="flex:1; background:rgba(96,165,250,0.08); border:1px solid rgba(96,165,250,0.3); border-radius:10px; padding:14px;">
    <div style="font-size:0.95em; font-weight:700; color:#93c5fd; margin-bottom:10px;">🔧 Next</div>
    <div style="display:flex; flex-direction:column; gap:6px;">
      <div style="font-size:0.78em; color:#94a3b8;">→ Benchmarks: LongBench-Pro · BrowseComp-Plus</div>
      <div style="font-size:0.78em; color:#94a3b8;">→ SmartRouter: adaptive routing improvements</div>
      <div style="font-size:0.78em; color:#94a3b8;">→ RAG + RLM integration patterns</div>
      <div style="font-size:0.78em; color:#94a3b8;">→ Token efficiency: prompt compression, evidence compression</div>
      <div style="font-size:0.78em; color:#94a3b8;">→ Speed: faster subcall model, early stopping</div>
      <div style="font-size:0.78em; color:#94a3b8;">→ Fine-tune larger models (Llama-70B, Qwen-480B)</div>
      <div style="font-size:0.78em; color:#94a3b8;">→ Multi-modal RLMs · Collaborative agents</div>
    </div>
  </div>
</div>

<!-- NOTAS — Roadmap
Esta slide resume el estado completo del proyecto de forma honesta.

COLUMNA IZQUIERDA: Lo entregado. Todo esto está en v0.3.0, disponible hoy en pip.
- MontyREPL: Rust sandbox. Secure by construction.
- Parallel subcalls: llm_batch + ask_chunks paralelos + flag global. ThreadPoolExecutor con 10 workers.
- Conversation history: Multi-turn self-correction. El LLM ve sus propios intentos previos.
- Elasticsearch retrieval: BM25 + kNN + hybrid RRF. Context opcional cuando hay retriever.
- VertexAI: Google Cloud support en v0.3.0.
- Live trace: RichTraceListener, visualización en tiempo real.
- SmartRouter: auto-selección baseline vs RLM. Configurable threshold.

COLUMNA DERECHA: Lo que viene. Estos son los issues abiertos en GitHub (ver repo para estado actual).
- Benchmarks (#10 BrowseComp-Plus): evaluación formal pendiente.
- SmartRouter improvements (#23): routing más sofisticado basado en task complexity.
- RAG + RLM (#22): patrones de integración formales (RAG como filtro, RLM como director, hybrid).
- Token efficiency (#14, #18, #19, #20, #21): 5 issues con impacto estimado de 20-50% reducción.
- Speed (#15, #16, #17): early stopping, subcall model más rápido, reduce max_steps.
- Fine-tuning: modelos más grandes con el dataset RLM-Qwen3.
- Multi-modal y collaborative: visión a más largo plazo.

Ver el repo en GitHub para el estado actual de cada issue.
-->

---

<!-- _class: invert -->

<div style="display:flex; align-items:center; justify-content:space-between; height:100%; padding:0 20px;">

<div style="flex:1; padding-right:40px;">
  <div style="font-size:2em; font-weight:700; margin-bottom:6px;">🙋 Questions?</div>
  <div style="color:#94a3b8; font-size:0.9em; margin-bottom:28px;">github.com/apenab/pyrlm-runtime</div>

  <div style="font-size:0.85em; color:#60a5fa; font-weight:600; margin-bottom:6px;">Try it yourself:</div>

```bash
pip install pyrlm-runtime
```

```python
from pyrlm_runtime import RLM, Context
from pyrlm_runtime.adapters import OpenAICompatAdapter

context = Context.from_documents([...])
rlm = RLM(adapter=OpenAICompatAdapter(model="gpt-4o"))
answer, trace = rlm.run("Your question", context)
```

  <div style="margin-top:16px; font-size:1.1em; font-weight:600; color:#e2e8f0;">Thank you!</div>
</div>

<div style="display:flex; flex-direction:column; align-items:center; gap:12px; min-width:200px;">
  <img src="images/qr-pyrlm.png" style="width:280px; height:280px; border-radius:12px; border:3px solid #60a5fa; padding:6px; background:white;" />
  <div style="font-size:0.72em; color:#60a5fa; text-align:center;">Scan to explore<br>the repo</div>
</div>

</div>

<!-- NOTAS — Questions / Cierre
Slide de cierre. El QR lleva al repo github.com/apenab/pyrlm-runtime.

Mencionar:
- pip install pyrlm-runtime para instalarlo hoy mismo
- El ejemplo es el mínimo viable: cargar documentos, crear el RLM, hacer la pregunta
- Cualquier pregunta, issue o PR es bienvenido en el repo
- Las slides y el código de ejemplos de la charla también estarán en el repo
-->
