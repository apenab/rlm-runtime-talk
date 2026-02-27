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

SETUP: Plantear el problema de forma directa. Los LLMs tienen límites de contexto. Si el libro tiene 500 páginas y el modelo solo aguanta 200, ¿qué hace? Se rinde o corta.

TRANSICIÓN: "¿Cuáles son las soluciones actuales? Vamos a verlas..."
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
    <div style="color:#94a3b8; font-size:0.85em;">Requires complex infrastructure</div>
  </div>
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:12px; visibility:hidden;">
    <div style="font-size:1.3em; margin-bottom:4px;">❌ Long-context</div>
    <div style="color:#94a3b8; font-size:0.85em;">Expensive and still have limits</div>
  </div>
</div>

<!--
NOTAS — The Problem We All Know (1/3)

CONTEXTO: Los LLMs actuales tienen ventanas de contexto limitadas (GPT-5: 272K tokens, ~200 páginas). Pero muchas tareas reales requieren procesar mucho más.

TRUNCATION: Simplemente corta el texto. Si la respuesta está en la parte cortada, se pierde. Es lo que hace el "baseline" en el paper.

TRANSICIÓN: "Bueno, truncar es malo. ¿Y si usamos RAG?"
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
    <div style="color:#94a3b8; font-size:0.85em;">Requires complex infrastructure</div>
  </div>
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:12px; visibility:hidden;">
    <div style="font-size:1.3em; margin-bottom:4px;">❌ Long-context</div>
    <div style="color:#94a3b8; font-size:0.85em;">Expensive and still have limits</div>
  </div>
</div>

<!--
NOTAS — The Problem We All Know (2/3)

RAG: Funciona bien para búsqueda de información localizada, pero falla cuando necesitas razonar sobre TODO el documento (ej: OOLONG, que requiere procesar cada línea).

TRANSICIÓN: "Ok, ¿y los modelos con ventanas de contexto enormes?"
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
    <div style="color:#94a3b8; font-size:0.85em;">Requires complex infrastructure</div>
  </div>
  <div style="flex:1; background:rgba(239,68,68,0.1); border:1px solid #ef4444; border-radius:10px; padding:12px;">
    <div style="font-size:1.3em; margin-bottom:4px;">❌ Long-context</div>
    <div style="color:#94a3b8; font-size:0.85em;">Expensive and still have limits</div>
  </div>
</div>

<!--
NOTAS — The Problem We All Know (3/3)

LONG-CONTEXT MODELS: Gemini 2.0 tiene 1M tokens, pero sufre "context rot" — el rendimiento se degrada con contextos largos. Y el coste escala linealmente con el input.

DATO DEL PAPER: Incluso GPT-5 con su ventana de 272K tokens pierde rendimiento significativo a partir de 16K tokens en tareas complejas (OOLONG-Pairs). No es solo un problema de tamaño de ventana, es un problema de cómo se procesa la información.

TRANSICIÓN: Context ROT
-->

---

# 📉 Context Rot is Real

<div class="columns">
<div>

**What happens:**

<div style="display:flex; flex-direction:column; gap:8px; margin-top:10px;">
  <div style="background:rgba(234,179,8,0.12); border:1px solid #eab308; border-radius:10px; padding:10px;">
    <div style="font-size:1.1em;">👁️ Sees the beginning</div>
  </div>
  <div style="background:rgba(234,179,8,0.12); border:1px solid #eab308; border-radius:10px; padding:10px;">
    <div style="font-size:1.1em;">👁️ Sees the end</div>
  </div>
  <div style="background:rgba(239,68,68,0.15); border:1px solid #ef4444; border-radius:10px; padding:10px;">
    <div style="font-size:1.1em;">🧠 <strong>But forgets the middle</strong></div>
  </div>
</div>

<div style="color:#94a3b8; font-size:0.85em; margin-top:10px;">Performance degrades as context grows, even within the model's supposed "window"</div>

</div>
<div>

**Example:**

```
"In chapter 1, Alice and Bob are alive...

[1000 pages of content]

...In chapter 25, Bob died.

[1000 pages of content]

...In chapter 50, who died in chapter 25?"

Model: "Alice" ❌
(It forgot the middle)
```

</div>
</div>

<!--
-->

---

# 💡 The Brilliant Insight from MIT

> **What if we treat the context as part of the _environment_ instead of loading it all into memory?**

Like a programmer with a huge file:

<!--
NOTAS — The Brilliant Insight from MIT (0/3)

La pregunta clave del paper: ¿y si el contexto no es algo que cargas, sino algo con lo que interactúas?

La analogía del programador: nadie carga un archivo de 10GB entero en memoria. Lo abres, buscas, filtras. ¿Por qué no hacemos lo mismo con los LLMs?

TRANSICIÓN: "Veamos cómo se traduce eso en práctica..."
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

<div style="background:linear-gradient(135deg, rgba(96,165,250,0.2), rgba(168,85,247,0.2)); border:2px solid #60a5fa; border-radius:12px; padding:12px; text-align:center !important; margin-top:16px; font-size:1.15em; font-weight:700; color:#e2e8f0; visibility:hidden;">
  🧠 This is <span style="color:#60a5fa;">RLM</span>: Recursive Language Models
</div>

<!--
NOTAS — The Brilliant Insight from MIT (1/3)

"¿Qué pasa si tratamos el contexto como parte del ENTORNO en vez de cargarlo todo en memoria?"

Pensémoslo como un programador: si tienes un archivo de 10GB, no lo cargas entero en RAM. Eso explotaría. Y sin embargo, eso es exactamente lo que hacemos con los LLMs — les metemos todo el contexto en el prompt.

TRANSICIÓN: "Entonces, ¿qué hacemos en vez de cargar todo? Buscamos bajo demanda."
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

<div style="background:linear-gradient(135deg, rgba(96,165,250,0.2), rgba(168,85,247,0.2)); border:2px solid #60a5fa; border-radius:12px; padding:12px; text-align:center !important; margin-top:16px; font-size:1.15em; font-weight:700; color:#e2e8f0; visibility:hidden;">
  🧠 This is <span style="color:#60a5fa;">RLM</span>: Recursive Language Models
</div>

<!--
NOTAS — The Brilliant Insight from MIT (2/3)

Buscar bajo demanda: abres el archivo, haces grep, filtras — solo inspeccionas lo que importa. No necesitas tener todo en memoria para encontrar lo que buscas.

TRANSICIÓN: "Pero ¿qué pasa cuando el archivo es tan grande que ni grep alcanza? Recursión: divide el problema, delega a sub-procesos, y une los resultados."
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

<div style="background:linear-gradient(135deg, rgba(96,165,250,0.2), rgba(168,85,247,0.2)); border:2px solid #60a5fa; border-radius:12px; padding:12px; text-align:center !important; margin-top:16px; font-size:1.15em; font-weight:700; color:#e2e8f0;">
  🧠 This is <span style="color:#60a5fa;">RLM</span>: Recursive Language Models
</div>

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

Estas 3 propiedades son lo que distingue un RLM de un agente con herramientas (como CodeAct o ReAct). Vamos a verlas una por una.

1. SYMBOLIC HANDLE: El contexto NO está en el prompt del LLM. Está como variable P en el REPL. El LLM solo ve metadata (longitud, estructura). Para ver el contenido, tiene que escribir código: peek(100), ctx.find("pattern"), etc. Esto es clave porque evita que el modelo sufra "context rot".

Por ejemplo, CodeAct tiene herramientas pero mete el contexto en el prompt — falla esta propiedad.

TRANSICIÓN: "Y si el contexto no está en el prompt... ¿dónde vive? En un entorno persistente."
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

2. PERSISTENT TURING-COMPLETE ENVIRONMENT: El REPL de Python persiste entre iteraciones. El modelo puede definir funciones, guardar variables, y construir lógica compleja paso a paso. No es un "one-shot" — es un loop iterativo. El paper lo describe como analogía con "out-of-core algorithms": memoria principal pequeña pero rápida (LLM) + almacenamiento externo grande (REPL con el contexto).

Summary agents comprimen el contexto — fallan esta propiedad porque no es persistente.

TRANSICIÓN: "Ok, tenemos el contexto fuera del modelo y un entorno persistente. Pero ¿qué pasa cuando el contexto es TAN grande que ni el REPL puede procesarlo de una vez? Recursión."
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

3. SYMBOLIC RECURSION: La función llm_query() permite que el RLM se llame a sí mismo con trozos del contexto. Cada subcall crea un RLM hijo (depth+1) con su propio REPL. Esto permite "divide and conquer": partir el contexto en chunks y procesarlos recursivamente. Es lo que permite escalar a 10M+ tokens.

ReAct usa tools pero no tiene recursión simbólica — falla esta propiedad.

IMPORTANTE: Un sistema que tenga las 3 propiedades ES un RLM. Si le falta alguna, NO lo es. Por ejemplo, CodeAct tiene herramientas pero mete el contexto en el prompt (falla propiedad 1). Summary agents comprimen el contexto (falla propiedad 2, no es persistente). ReAct usa tools pero no tiene recursión simbólica (falla propiedad 3).

TRANSICIÓN: "Ahora que conocemos las 3 propiedades, veamos cómo se conectan en la arquitectura completa."
-->

---

# 🎯 Architecture: RLM High-Level View

<table style="width:100%; border-collapse:separate; border-spacing:0; background:rgba(30,58,95,0.5); border:2px solid #3b82f6; border-radius:14px; margin-top:10px;">
<tr><td colspan="5" style="padding:8px 14px; font-size:20px; font-weight:800; color:#93c5fd; border:none;">RLM (root / depth = 0)</td></tr>
<tr style="vertical-align:middle;">
  <td style="border:none; padding:10px; width:15%; text-align:center;">
    <div style="background:rgba(234,179,8,0.15); border:2px solid #eab308; color:#fde68a; border-radius:10px; padding:10px; font-weight:600; font-size:18px; margin-bottom:8px;">📋 query</div>
    <div style="background:rgba(234,179,8,0.15); border:2px solid #eab308; color:#fde68a; border-radius:10px; padding:10px; font-weight:600; font-size:18px;">📄 context<br><span style="font-size:14px;">(1M tokens)</span></div>
  </td>
  <td style="border:none; padding:5px; font-size:28px; color:#94a3b8; text-align:center; width:5%;">→</td>
  <td style="border:none; padding:10px; text-align:center; width:50%;">
    <div style="background:rgba(34,197,94,0.15); border:2px solid #22c55e; color:#86efac; border-radius:10px; padding:12px; font-weight:600; font-size:20px;">🧠 Language Model</div>
    <div style="font-size:16px; color:#94a3b8; margin:4px 0;">code ↓ &nbsp;&nbsp;<span style="font-size:28px; color:#60a5fa; font-weight:900;">⟳</span>&nbsp;&nbsp; ↑ stdout</div>
    <div style="background:rgba(239,68,68,0.15); border:2px solid #ef4444; color:#fca5a5; border-radius:10px; padding:10px; font-weight:600; font-size:19px;">⚙️ Environment E (Python REPL)<br>
      <span style="font-size:14px; font-weight:400; color:#cbd5e1;">P = context · llm_query() · extract_after() · peek()</span>
    </div>
    <div style="font-size:15px; color:#94a3b8; font-style:italic; margin-top:4px;">Context stays here — never sent to LLM directly</div>
  </td>
  <td style="border:none; padding:5px; font-size:28px; color:#94a3b8; text-align:center; width:5%;">→</td>
  <td style="border:none; padding:10px; width:15%; text-align:center;">
    <div style="background:rgba(168,85,247,0.15); border:2px solid #a855f7; color:#d8b4fe; border-radius:10px; padding:10px; font-weight:600; font-size:18px;">✅ final<br>response</div>
    <div style="font-size:14px; color:#94a3b8; font-style:italic; margin-top:4px;">FINAL: / FINAL_VAR:</div>
  </td>
</tr>
<tr><td colspan="5" style="border:none; text-align:center; padding:6px; font-size:16px;">
  <span style="color:#94a3b8;">REPL calls </span>
  <code style="font-size:16px; color:#f87171; font-weight:700; background:transparent;">llm_query(sub_context)</code>
  <span style="color:#94a3b8;"> → spawns child RLMs ↓</span>
</td></tr>
</table>

<!--
NOTAS — Slide: Architecture High-Level View

Este diagrama muestra la vista de pájaro de cómo funciona un RLM (paper MIT CSAIL, Figure 2).

ZONA SUPERIOR — RLM Root (depth=0):
- A la izquierda entran el query y el contexto (puede ser 500 páginas, 1M+ tokens).
- El contexto NO se envía al LLM. Se almacena como variable P en un Python REPL.
- El LLM (verde) solo recibe metadata: longitud, estructura, nº de documentos.
- El LLM genera código → se ejecuta en el REPL → stdout vuelve al LLM. Esto forma un loop iterativo (⟳).
- El REPL tiene funciones clave: llm_query() para subcalls recursivos, extract_after() para búsqueda determinista, peek()/chunk().
- El loop termina cuando el LLM emite FINAL: o FINAL_VAR:.

ZONA INFERIOR — Child RLMs (depth=1):
- Cuando el Root LLM llama a llm_query(sub_context), se crea un RLM hijo.
- Cada hijo tiene su propio sub-query, sub-context, LM y REPL.
- Los hijos pueden crear más hijos (depth=2, 3...) — recursión arbitraria.
- Los resultados vuelven al REPL del padre como variables.

ANALOGÍA: "Es como un programador que no carga un archivo gigante en RAM. Lo abre, busca con grep/regex, y delega trozos a funciones auxiliares."
-->

---

# 🎯 Architecture: RLM High-Level View

  <div style="background:rgba(148,163,184,0.1); border:2px dashed #64748b; border-radius:12px; padding:12px;">
    <div style="font-size:17px; font-weight:700; color:#cbd5e1; margin-bottom:8px;">RLM (depth=1) — chunk 1</div>
    <div style="text-align:center; font-size:17px;">
      <span style="background:rgba(234,179,8,0.15); border:2px solid #eab308; color:#fde68a; border-radius:8px; padding:4px 10px; font-weight:600;">sub-query</span>
      &nbsp;→&nbsp;
      <span style="background:rgba(34,197,94,0.15); border:2px solid #22c55e; color:#86efac; border-radius:8px; padding:4px 10px; font-weight:600;">🧠 LM</span>
      &nbsp;<span style="color:#60a5fa; font-size:20px;">⟳</span>&nbsp;
      <span style="background:rgba(239,68,68,0.15); border:2px solid #ef4444; color:#fca5a5; border-radius:8px; padding:4px 10px; font-weight:600;">⚙️ REPL</span>
      &nbsp;→&nbsp;
      <span style="background:rgba(168,85,247,0.15); border:2px solid #a855f7; color:#d8b4fe; border-radius:8px; padding:4px 10px; font-weight:600;">sub-response</span>
    </div>
  </div>
  <br/>
  <br/>
  <br/>
<div style="background:rgba(148,163,184,0.1); border:2px dashed #64748b; border-radius:12px; padding:12px;">
    <div style="font-size:17px; font-weight:700; color:#cbd5e1; margin-bottom:8px;">RLM (depth=1) — chunk 2</div>
    <div style="text-align:center; font-size:17px;">
      <span style="background:rgba(234,179,8,0.15); border:2px solid #eab308; color:#fde68a; border-radius:8px; padding:4px 10px; font-weight:600;">sub-query</span>
      &nbsp;→&nbsp;
      <span style="background:rgba(34,197,94,0.15); border:2px solid #22c55e; color:#86efac; border-radius:8px; padding:4px 10px; font-weight:600;">🧠 LM</span>
      &nbsp;<span style="color:#60a5fa; font-size:20px;">⟳</span>&nbsp;
      <span style="background:rgba(239,68,68,0.15); border:2px solid #ef4444; color:#fca5a5; border-radius:8px; padding:4px 10px; font-weight:600;">⚙️ REPL</span>
      &nbsp;→&nbsp;
      <span style="background:rgba(168,85,247,0.15); border:2px solid #a855f7; color:#d8b4fe; border-radius:8px; padding:4px 10px; font-weight:600;">sub-response</span>
    </div>
    <div style="text-align:center; margin-top:6px; font-size:22px; color:#64748b; letter-spacing:8px;">⋯ ⋯ ⋯</div>
  </div>

---

# 🔄 Architecture: The Iterative REPL Loop

<table style="width:100%; border-collapse:collapse; margin-top:4px;">
<tr style="vertical-align:top;">

<td style="border:none; width:22%; padding-right:14px;">
  <div style="background:rgba(34,197,94,0.15); border:2px solid #22c55e; color:#86efac; border-radius:10px; padding:10px; text-align:center; font-weight:600; font-size:17px;">
    🧠 Root LM<br><span style="font-size:13px; font-weight:400; color:#94a3b8;">(depth = 0)</span>
  </div>
  <div style="text-align:center; font-size:18px; color:#94a3b8; font-weight:bold;">↓</div>
  <div style="background:rgba(234,179,8,0.15); border:2px solid #f59e0b; border-radius:8px; padding:8px; font-size:14px; color:#fde68a;">
    <strong>System prompt:</strong><br>
    <span style="color:#cbd5e1;">"Answer {query}. Interact with REPL which has <code style="font-size:13px; background:transparent; color:#60a5fa;">context</code>..."</span>
  </div>
  <div style="text-align:center; font-size:18px; color:#94a3b8; font-weight:bold;">↓</div>
  <div style="background:rgba(34,197,94,0.1); border:2px solid #22c55e; border-radius:8px; padding:8px; font-size:14px; color:#86efac;">
    <strong>LM Output:</strong><br>
    <code style="font-size:13px; background:#0f172a; color:#a5f3fc; padding:2px 6px; border-radius:3px;">execute_code(...)</code>
  </div>
  <div style="text-align:center; font-size:18px; color:#94a3b8; font-weight:bold;">↓</div>
  <div style="background:rgba(239,68,68,0.1); border:2px solid #ef4444; border-radius:8px; padding:8px; font-size:14px; color:#fca5a5;">
    <strong>REPL stdout:</strong><br>
    <span style="font-family:monospace; font-size:13px; color:#cbd5e1;">"Best match: Ally of Justice Catastor..."</span>
  </div>
  <div style="text-align:center; font-size:30px; color:#60a5fa; font-weight:900;">⟳</div>
  <div style="text-align:center; font-size:13px; color:#94a3b8; font-style:italic;">Loop until FINAL</div>
  <div style="text-align:center; font-size:18px; color:#94a3b8; font-weight:bold;">↓</div>
  <div style="background:rgba(168,85,247,0.15); border:2px solid #a855f7; border-radius:8px; padding:8px; font-size:14px; color:#d8b4fe;">
    <strong>LM Output:</strong><br>
    <code style="font-size:13px; background:#0f172a; color:#c4b5fd; padding:2px 6px; border-radius:3px;">FINAL(answer)</code>
  </div>
</td>

<td style="border:none; padding-left:14px; visibility:hidden;"></td>

</tr>
</table>

<!--
NOTAS — Architecture: The Iterative REPL Loop (1/2)

COLUMNA IZQUIERDA — Flujo del Root LM:
- El Root LM recibe un system prompt: "Tienes un contexto en la variable context, interactúa con el REPL."
- En cada iteración, el LM genera código (execute_code).
- El REPL ejecuta el código y devuelve stdout (truncado a ~2000 chars).
- CONVERSATION HISTORY: El stdout Y la respuesta del LM se appenden al historial acumulativo. En la siguiente iteración, el LM ve TODOS sus intentos anteriores (código + resultados). Esto permite autocorrección.
- El loop (⟳) se repite hasta FINAL(respuesta).

TRANSICIÓN: "Ahora veamos qué pasa dentro del REPL..."
-->

---

# 🔄 Architecture: The Iterative REPL Loop

<table style="width:100%; border-collapse:collapse; margin-top:4px;">
<tr style="vertical-align:top;">

<td style="border:none; width:22%; padding-right:14px;">
  <div style="background:rgba(34,197,94,0.15); border:2px solid #22c55e; color:#86efac; border-radius:10px; padding:10px; text-align:center; font-weight:600; font-size:17px;">
    🧠 Root LM<br><span style="font-size:13px; font-weight:400; color:#94a3b8;">(depth = 0)</span>
  </div>
  <div style="text-align:center; font-size:18px; color:#94a3b8; font-weight:bold;">↓</div>
  <div style="background:rgba(234,179,8,0.15); border:2px solid #f59e0b; border-radius:8px; padding:8px; font-size:14px; color:#fde68a;">
    <strong>System prompt:</strong><br>
    <span style="color:#cbd5e1;">"Answer {query}. Interact with REPL which has <code style="font-size:13px; background:transparent; color:#60a5fa;">context</code>..."</span>
  </div>
  <div style="text-align:center; font-size:18px; color:#94a3b8; font-weight:bold;">↓</div>
  <div style="background:rgba(34,197,94,0.1); border:2px solid #22c55e; border-radius:8px; padding:8px; font-size:14px; color:#86efac;">
    <strong>LM Output:</strong><br>
    <code style="font-size:13px; background:#0f172a; color:#a5f3fc; padding:2px 6px; border-radius:3px;">execute_code(...)</code>
  </div>
  <div style="text-align:center; font-size:18px; color:#94a3b8; font-weight:bold;">↓</div>
  <div style="background:rgba(239,68,68,0.1); border:2px solid #ef4444; border-radius:8px; padding:8px; font-size:14px; color:#fca5a5;">
    <strong>REPL stdout:</strong><br>
    <span style="font-family:monospace; font-size:13px; color:#cbd5e1;">"Best match: Ally of Justice Catastor..."</span>
  </div>
  <div style="text-align:center; font-size:30px; color:#60a5fa; font-weight:900;">⟳</div>
  <div style="text-align:center; font-size:13px; color:#94a3b8; font-style:italic;">Loop until FINAL</div>
  <div style="text-align:center; font-size:18px; color:#94a3b8; font-weight:bold;">↓</div>
  <div style="background:rgba(168,85,247,0.15); border:2px solid #a855f7; border-radius:8px; padding:8px; font-size:14px; color:#d8b4fe;">
    <strong>LM Output:</strong><br>
    <code style="font-size:13px; background:#0f172a; color:#c4b5fd; padding:2px 6px; border-radius:3px;">FINAL(answer)</code>
  </div>
</td>

<td style="border:none; padding-left:14px;">
  <div style="font-size:22px; font-weight:800; color:#e2e8f0; font-family:'Consolas',monospace; margin-bottom:8px;">
    📓 REPL Python Notebook
  </div>

  <div style="font-size:15px; font-weight:700; color:#94a3b8;">In[1]</div>
  <div style="background:#0f172a; color:#a5f3fc; font-family:'Consolas',monospace; font-size:13px; padding:8px 12px; border-radius:6px; line-height:1.5; text-align:left !important;">
    <span style="color:#6ee7b7;"># Split context for sub-LLM processing</span><br>
    half = len(context) // 2<br>
    first_half = "\n".join(context[:half])<br>
    <span style="color:#6ee7b7;"># Recursive LM subcall</span><br>
    ans1 = <span style="color:#fbbf24; font-weight:700;">llm_query</span>(query + first_half)<br>
    print(ans1[:2000])
  </div>
  <table style="width:100%; border-collapse:collapse; margin:6px 0;"><tr>
    <td style="border:none; font-size:15px; font-weight:700; color:#94a3b8; width:50px;">Out[1]</td>
    <td style="border:none; background:rgba(148,163,184,0.1); border:1px solid #475569; border-radius:6px; padding:6px 10px; font-size:13px; font-family:monospace; color:#cbd5e1; text-align:left !important; ">Best single match: Ally of Justice Catastor → ✓</td>
    <td style="border:none; width:120px; background:rgba(234,179,8,0.15); border:1px solid #f59e0b; border-radius:6px; padding:4px 8px; font-size:13px; text-align:center; color:#fde68a;">↗️ <strong>llm_query()</strong><br><span style="font-size:11px;">Recursive d=1</span></td>
  </tr></table>

  <div style="text-align:center; font-size:24px; color:#64748b; letter-spacing:6px;">⋮ &nbsp; ⋮ &nbsp; ⋮</div>

  <div style="font-size:15px; font-weight:700; color:#94a3b8;text-align:left !important; margin-bottom:3px;">In[N]</div>
  <div style="background:#0f172a; color:#a5f3fc; font-family:'Consolas',monospace; font-size:13px; padding:8px 12px; border-radius:6px; line-height:1.5; text-align:left !important; margin-bottom: 20px">
    <span style="color:#6ee7b7;"># Verify chunk 18 contains the evidence</span><br>
    chunk18 = context[18]<br>
    excerpt = find_excerpt(chunk18, "illegal to play")<br>
    print("Excerpt:", excerpt or "Not Found")
  </div>
  <div style="font-size:15px; font-weight:700; color:#94a3b8; margin-top:4px;text-align:left !important; margin-bottom:3px">Out[N]</div>
  <div style="background:rgba(148,163,184,0.1); border:1px solid #475569; border-radius:6px; padding:6px 10px; font-size:13px; font-family:monospace; color:#cbd5e1; text-align:left !important">
    Excerpt: "...Catastor appears in the artwork of Blue Pollinator..."
  </div>
</td>

</tr>
</table>

<!--

COLUMNA IZQUIERDA — Flujo del Root LM:
- El Root LM recibe un system prompt: "Tienes un contexto en la variable context, interactúa con el REPL."
- En cada iteración, el LM genera código (execute_code).
- El REPL ejecuta el código y devuelve stdout (truncado a ~2000 chars).
- CONVERSATION HISTORY: El stdout Y la respuesta del LM se appenden al historial acumulativo. En la siguiente iteración, el LM ve TODOS sus intentos anteriores (código + resultados). Esto permite autocorrección: si el código falla, el LM ve el error Y su código anterior.
- El loop (⟳) se repite hasta FINAL(respuesta) o FINAL_VAR(variable).

COLUMNA DERECHA — REPL Python Notebook:
- In[1]: Ejemplo real del paper (BrowseComp+). El LLM divide el contexto en mitades y usa llm_query() para hacer un subcall recursivo — esto crea un RLM hijo (depth=1).
- Out[1]: El resultado del subcall vuelve como texto al REPL. El badge amarillo indica que se hizo una llamada recursiva.
- In[N]: En iteraciones posteriores, el LLM escribe funciones de verificación para confirmar evidencia.

PUNTO CLAVE para decir en voz alta:
"El LLM NUNCA ve el contexto completo. Solo ve metadata y stdout truncado del REPL. Toda la inspección ocurre mediante código. Las llamadas a llm_query() disparan sub-RLMs recursivos sobre trozos más pequeños. Y gracias al historial conversacional multi-turno, el LLM puede autocorregirse viendo sus intentos anteriores — si un chunk no tenía la respuesta, el LLM ya lo sabe y prueba otro."
-->

---

# ⚙️ Algorithm 1: The Correct Design

```python
def RLM(prompt_P):
    state = InitREPL(prompt=P)
    state.add_function(sub_RLM)  # Recursive calls!
    hist = [SystemPrompt, Metadata(state)]

    while True:
        response = LLM(hist)           # LLM sees FULL history
        hist = hist || response         # Append assistant turn
        (state, stdout) = REPL(state, response.code)
        hist = hist || Result(stdout)   # Append REPL feedback

        if state[Final] is set:
            return state[Final]
```

**Key:** Context stays in REPL. LLM sees all previous attempts and self-corrects.

<!--
Línea por línea:
1. InitREPL(prompt=P): Crea un entorno Python con P como variable. El LLM NO ve P directamente.
2. state.add_function(sub_RLM): Registra la función de recursión. El código del LLM puede llamar a llm_query() o ask_chunks().
3. hist = [SystemPrompt, Metadata(state)]: El historial empieza con el system prompt + metadata del contexto (longitud, tipo, nº documentos). El LLM NUNCA ve P completo.
4. LOOP: El LLM recibe el historial COMPLETO (todos los turnos anteriores). Genera código → se ejecuta → el resultado se appenda como turno "user". Esto permite al LLM VER sus intentos anteriores y autocorregirse.
5. state[Final]: Cuando el LLM emite FINAL: o FINAL_VAR:, el loop termina.

CLAVE: hist crece como [system, user_initial, assistant(code), user(stdout), assistant(code), user(stdout), ...]. Cada iteración el LLM ve toda la conversación. Esto es FUNDAMENTAL para la autocorrección — si el código falla, el LLM ve el error Y su código anterior.

NUESTRA IMPLEMENTACIÓN: En src/pyrlm_runtime/rlm.py → método run(), el campo conversation_history=True activa este comportamiento. Con max_history_tokens se puede limitar el presupuesto de tokens para evitar desbordar la ventana de contexto. La función _trim_history() preserva siempre el system prompt + primer user message, y recorta turnos antiguos del medio.

BACKWARD COMPAT: Con conversation_history=False se mantiene el comportamiento anterior (stateless, 2 mensajes por llamada).
-->

---

# ❌ Algorithm 2: Poor Design (Comparison)

```python
def PoorDesign(prompt_P):
    actions = {Finish, Exec, Search, sub_LLM}
    hist = [Metadata(actions), P]  # Flaw #1: P in hist

    while True:
        (action, val) = LLM(hist)  # Flaw #2: sees P directly

        if action is Finish:
            return val

        out = RUN(action, val)  # Flaw #3: limited actions
        hist = hist || (action, val, out)

        if len(hist) > K:
            hist = Compact(hist)  # Flaw #4: lossy
```

**Why it fails:** Context directly in prompt → truncation

<!--
NOTAS — Algorithm 2: Poor Design

Este es el anti-patrón. Representa cómo funcionan la mayoría de agentes actuales (CodeAct, ReAct, etc.):

FLAW #1 - P en hist: El contexto completo se mete en el prompt del LLM. Si P > ventana de contexto → truncación inevitable.
FLAW #2 - LLM ve P directamente: El modelo tiene que "leer" todo el contexto en su atención. Esto causa context rot incluso si cabe.
FLAW #3 - Acciones limitadas: Las herramientas son predefinidas (Search, Exec). No es Turing-complete como un REPL Python.
FLAW #4 - Compact lossy: Cuando el historial crece, se comprime con summarización. Esto pierde información. Es lo que hacen Claude Code, Cursor, etc. con su "context compaction".

COMPARACIÓN DIRECTA:
- Algorithm 1: P NUNCA está en hist → escala infinitamente
- Algorithm 2: P SIEMPRE está en hist → limitado por ventana de contexto

NOTA SOBRE NUESTRO TRIMMING: En pyrlm-runtime implementamos _trim_history() que recorta turnos antiguos del MEDIO del historial, pero SIEMPRE preserva el system prompt + primer user message (que contiene la metadata del contexto). Esto es diferente del "Compact lossy" del Algorithm 2 porque: (1) nunca perdemos el contexto de la tarea original, (2) solo recortamos turnos intermedios de código+stdout que ya se procesaron, (3) siempre mantenemos los turnos más recientes que son los más relevantes para la autocorrección.

Pregunta para la audiencia: "¿Cuántos de ustedes han usado un agente que les dice 'contexto demasiado largo, resumiendo...'? Eso es Algorithm 2."
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

Este ejemplo simplificado ilustra la diferencia fundamental:

BASELINE: Intenta meter todo el contexto en el prompt. Si el contexto tiene 1M tokens y la ventana es 128K, trunca. Si la "aguja" (el key term) está después de la posición 128K, se pierde para siempre. Game over.

RLM — PHASE 0 (deterministic): Antes de hacer cualquier subcall al LLM, intenta extract_after('key term is:'). Esta es una búsqueda de string pura en Python — O(n), sin coste de API, funciona sobre cualquier longitud. Si encuentra la aguja → 0 subcalls, coste $0. En mi rlm-runtime esto es la optimización "Deterministic Phase 0" que implementé en el fallback_code.

RLM — PHASE 1 (si Phase 0 falla): Divide el contexto en chunks de 5000 chars, hace subcalls al LLM para cada chunk ("¿hay un key term aquí?"), y pick_first_answer devuelve la primera respuesta válida.

DATO: En el benchmark S-NIAH (Simple Needle in a Haystack) del paper, el RLM(GPT-5) mantiene ~95% de accuracy incluso a 1M tokens, mientras que GPT-5 base degrada a ~80% a 262K tokens y no puede procesar más allá de eso.

OJO: Este ejemplo es simplificado. En la realidad, las tareas son más complejas que buscar un string. Pero ilustra el principio.
-->

---

# 📊 MIT Paper Results: GPT-5

<table style="width:100%; border-collapse:separate; border-spacing:0; margin-top:14px; font-size:1em;">
  <thead>
    <tr>
      <th style="background:rgba(96,165,250,0.2); border:1px solid #3b82f6; border-radius:0; padding:10px 14px; text-align:center; color:#93c5fd; font-size:1em;">Task</th>
      <th style="background:rgba(96,165,250,0.2); border:1px solid #3b82f6; padding:10px 14px; text-align:center; color:#93c5fd; font-size:1em;">GPT-5 Base</th>
      <th style="background:rgba(96,165,250,0.2); border:1px solid #3b82f6; padding:10px 14px; text-align:center; color:#93c5fd; font-size:1em;">RLM(GPT-5)</th>
      <th style="background:rgba(96,165,250,0.2); border:1px solid #3b82f6; padding:10px 14px; text-align:center; color:#93c5fd; font-size:1em;">Gain</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; font-weight:700; color:#e2e8f0; font-size:1.05em;">CodeQA</td>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; color:#fca5a5; font-size:1.1em;">24%<sup style="font-size:0.7em;">*</sup></td>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; color:#86efac; font-weight:700; font-size:1.3em;">62%</td>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; color:#fde68a; font-weight:700; font-size:1.1em;">2.6x 🚀</td>
    </tr>
    <tr style="background:rgba(255,255,255,0.03);">
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; font-weight:700; color:#e2e8f0; font-size:1.05em;">BrowseComp+ <span style="color:#64748b; font-weight:400; font-size:0.85em;">(1K docs)</span></td>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; color:#fca5a5; font-size:1.1em;">0%<sup style="font-size:0.7em;">*</sup></td>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; color:#86efac; font-weight:700; font-size:1.3em;">91.3%</td>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; color:#fde68a; font-weight:700; font-size:1.1em;">∞ ✅</td>
    </tr>
    <tr>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; font-weight:700; color:#e2e8f0; font-size:1.05em;">OOLONG</td>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; color:#fcd34d; font-size:1.1em;">44%</td>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; color:#86efac; font-weight:700; font-size:1.3em;">56.5%</td>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; color:#fde68a; font-weight:700; font-size:1.1em;">1.3x</td>
    </tr>
    <tr style="background:rgba(255,255,255,0.03);">
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; font-weight:700; color:#e2e8f0; font-size:1.05em;">OOLONG-Pairs</td>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; color:#fca5a5; font-size:1.1em;">0.1%</td>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; color:#86efac; font-weight:700; font-size:1.3em;">58%</td>
      <td style="border:1px solid #1e3a5f; padding:11px 14px; text-align:center; color:#fde68a; font-weight:700; font-size:1.1em;">580x 🤯</td>
    </tr>
  </tbody>
</table>

<div style="color:#64748b; font-size:0.8em; margin-top:8px;">* Hit context limits — Source: Table 1, MIT CSAIL paper (2025)</div>

**Key insight:** Baseline fails when context > window, RLM scales

<!--
NOTAS — MIT Paper Results: GPT-5

QUÉ SON ESTOS BENCHMARKS (empezar por aquí):
Antes de entrar en los números, hay que entender qué mide cada tarea — están diseñados para estresar el problema de contexto largo en distintas dimensiones.

- CodeQA: comprensión de repositorios de código enteros (23K–4.2M tokens). El modelo responde preguntas sobre el repo. Métrica: % de aciertos.
- BrowseComp+: búsqueda en 1000 documentos (6M–11M tokens). Literalmente imposible para un modelo con ventana finita. Métrica: % de aciertos.
- OOLONG: agregación semántica sobre miles de entradas (131K tokens). Cabe en la ventana de GPT-5, pero requiere procesar todo. Métrica: scoring propio del paper.
- OOLONG-Pairs: razonamiento sobre pares de entidades (32K tokens). Solo 32K — cabe perfectamente en GPT-5. Lo que falla no es el tamaño del contexto sino la complejidad de la tarea. Métrica: F1 score.

RESULTADOS fila a fila (números verificados contra Table 1 del paper — * = se quedó sin ventana):

- CodeQA: Base 24%* → RLM 62%. Ganancia 2.6x.
- BrowseComp+: Base 0%* (no puede procesarlo) → RLM 91.3%. Ganancia infinita.
- OOLONG: Base 44% → RLM 56.5%. El contexto SÍ cabe en GPT-5 y aun así el RLM mejora — no es solo un problema de tamaño de ventana.
- OOLONG-Pairs: Base 0.1% → RLM 58%. 580x. El más llamativo: 32K tokens caben perfectamente, pero el base no puede con la tarea.

TRANSICIÓN: "¿Y qué pasa cuando escalamos el contexto? La siguiente slide lo muestra."
-->

---

# 📈 Performance Degradation Comparison

**S-NIAH, OOLONG, OOLONG-Pairs benchmarks** — As context grows (8K → 1M tokens):

<div style="display:flex; gap:14px; margin-top:12px;">
  <div style="flex:1; background:rgba(239,68,68,0.12); border:2px solid #ef4444; border-radius:12px; padding:16px;">
    <div style="font-size:1.4em; margin-bottom:6px; text-align:center !important;">📉</div>
    <div style="font-size:1em; font-weight:700; color:#fca5a5; text-align:center !important;">GPT-5 baseline</div>
    <div style="display:flex; justify-content:center; align-items:center; gap:8px; margin-top:8px;">
      <span style="font-size:1.4em; font-weight:700; color:#86efac;">80%</span>
      <span style="color:#64748b; font-size:1.2em;">→</span>
      <span style="font-size:1.4em; font-weight:700; color:#ef4444;">20%</span>
    </div>
    <div style="font-size:0.75em; color:#94a3b8; text-align:center !important; margin-top:4px;">accuracy collapses</div>
  </div>
  <div style="flex:1; background:rgba(34,197,94,0.12); border:2px solid #22c55e; border-radius:12px; padding:16px;">
    <div style="font-size:1.4em; margin-bottom:6px; text-align:center !important;">✅</div>
    <div style="font-size:1em; font-weight:700; color:#86efac; text-align:center !important;">RLM(GPT-5)</div>
    <div style="display:flex; justify-content:center; align-items:center; gap:8px; margin-top:8px;">
      <span style="font-size:1.4em; font-weight:700; color:#86efac;">95%</span>
      <span style="color:#64748b; font-size:1.2em;">→</span>
      <span style="font-size:1.4em; font-weight:700; color:#86efac;">90%</span>
    </div>
    <div style="font-size:0.75em; color:#94a3b8; text-align:center !important; margin-top:4px;">barely degrades</div>
  </div>
</div>
<div style="display:flex; gap:10px; margin-top:14px;">
  <div style="flex:1; background:rgba(239,68,68,0.08); border:1px solid #475569; border-radius:8px; padding:10px; display:flex; align-items:center; gap:10px;">
    <span style="font-size:1.3em;">✂️</span>
    <div><span style="color:#fca5a5; font-weight:600;">Baseline truncates</span><span style="color:#94a3b8;"> → loses information</span></div>
  </div>
  <div style="flex:1; background:rgba(34,197,94,0.08); border:1px solid #475569; border-radius:8px; padding:10px; display:flex; align-items:center; gap:10px;">
    <span style="font-size:1.3em;">🔍</span>
    <div><span style="color:#86efac; font-weight:600;">RLM inspects</span><span style="color:#94a3b8;"> → no truncation</span></div>
  </div>
</div>
<br/>
<div style="flex:1; background:rgba(96,165,250,0.08); border:1px solid #475569; border-radius:8px; padding:10px; display:flex; align-items:center; gap:10px; justify-content:center">
    <span style="font-size:1.3em;">💰</span>
    <div><span style="color:#93c5fd; font-weight:600;">Cost</span><span style="color:#94a3b8;"> → log-linear, not exponential</span></div>
  </div>

<!--
NOTAS — Performance Degradation Comparison

Esto corresponde a la Figure 1 del paper — el gráfico más impactante. Aquí ya no miramos los números absolutos sino cómo se comportan ambos modelos a medida que el contexto crece de 8K a 1M tokens.

COMPLEJIDAD DE LA TAREA importa más que el tamaño del contexto:
- S-NIAH (complejidad O(1)): el needle no crece con el contexto. GPT-5 aguanta ~80-95% hasta 128K tokens, luego colapsa. RLM mantiene ~95% hasta 1M.
- OOLONG (complejidad O(N)): cada entrada necesita procesarse. GPT-5 degrada progresivamente. RLM mantiene rendimiento.
- OOLONG-Pairs (complejidad O(N²)): cada PAR de entradas. GPT-5 colapsa rápido. El paper lo llama "emergent capability" del RLM — puede manejar tareas cuadráticas que el base simplemente no puede.

CITA DEL PAPER: "GPT-5 performance degrades significantly faster for more complex tasks, while RLM performance degrades but at a much slower rate." A partir de ~16K tokens, el RLM consistentemente supera a GPT-5.

COSTE: El RLM escala proporcionalmente a la complejidad, pero se mantiene en el mismo orden de magnitud. En BrowseComp+ es hasta 3x más barato que un summary agent equivalente. El coste es log-linear, no exponencial.

CROSSOVER POINT: El base LM supera al RLM en contextos pequeños — el overhead del REPL no compensa para contextos cortos. Esto es exactamente lo que motiva el SmartRouter en rlm-runtime: enrutar al RLM solo cuando merece la pena.
-->

---

# 🎯 Breakthrough: RLM-Qwen3-8B

**The first natively trained RLM model** (January 2026)

<div style="display:flex; gap:12px; margin-top:12px;">
  <div style="flex:2; background:rgba(96,165,250,0.1); border:1px solid #60a5fa; border-radius:10px; padding:12px;">
    <div style="font-size:1em; font-weight:700; color:#93c5fd; margin-bottom:8px;">🏋️ Training</div>
    <div style="font-size:0.82em; color:#cbd5e1; line-height:1.6;">
      <b>Base:</b> Qwen3-8B<br>
      <b>Data:</b> ~1,072 RLM trajectories (filtered from 2,250)<br>
      <b>Source:</b> Qwen3-Coder-480B-A35B · 750 LongBenchPro tasks<br>
      <b>Run:</b> prime-rl · 300 steps · ~48 H100 hours<br>
      <b>Domain:</b> Unrelated to eval benchmarks
    </div>
  </div>
  <div style="flex:1; background:rgba(34,197,94,0.1); border:1px solid #22c55e; border-radius:10px; padding:12px;">
    <div style="font-size:1em; font-weight:700; color:#86efac; margin-bottom:8px;">📈 CodeQA results</div>
    <div style="font-size:0.85em; color:#cbd5e1; line-height:2;">
      Base Qwen3-8B: <span style="color:#fca5a5;">4%</span><br>
      + RLM scaffold: <span style="color:#fde68a;">26%</span><br>
      + Post-trained: <span style="color:#86efac; font-weight:700; font-size:1.1em;">32% 🚀</span>
    </div>
  </div>
</div>

<!--
NOTAS — Breakthrough: RLM-Qwen3-8B

Este es uno de los resultados más interesantes del paper. Demuestra que se puede ENTRENAR un modelo para ser un RLM.

CONTEXTO: El paper menciona en Appendix A que "Models without sufficient coding capabilities struggle as RLMs" y que Qwen3-8B "struggled without sufficient coding abilities." Pero con fine-tuning sobre ~1000 trayectorias RLM, el modelo aprende estrategias recursivas.

DATOS: No son del paper principal sino del blog de Alex Zhang. El modelo RLM-Qwen3-8B está publicado en HuggingFace (alexzhang/RLM-Qwen3-8B).

POST-TRAINING vs SCAFFOLD:
- Qwen3-8B vanilla (sin scaffold): 4% en CodeQA — el modelo no sabe qué hacer con el REPL.
- Qwen3-8B + scaffold RLM (sin fine-tuning): 26% — el scaffold le dice cómo, pero el modelo es ineficiente: hace demasiados subcalls, chunking subóptimo.
- RLM-Qwen3-8B (post-trained): 32% — el modelo ha "aprendido" las estrategias óptimas del entrenamiento. Menos subcalls, mejor chunking, más eficiente desde el primer paso.

IMPLICACIÓN: Runtime + modelo post-trained se complementan. El runtime provee la infraestructura (REPL, subcalls, caching), el modelo provee la inteligencia optimizada. Mi primera impresión era que el modelo post-trained iba a sustituir al runtime, pero no: se complementan.

OBSERVACIÓN NUEVA: Entrenar RLMs en un dominio puede mejorar el rendimiento general downstream (Observation 6 en la nueva versión del paper). Aquí se reporta un +28.3% promedio vs base Qwen3-8B.
-->

---

# 📊 Qwen3-8B: Vanilla vs Scaffold vs Post-trained

<table style="width:100%; border-collapse:separate; border-spacing:0; margin-top:10px; font-size:1em;">
  <thead>
    <tr>
      <th style="background:rgba(96,165,250,0.2); border:1px solid #3b82f6; padding:8px 12px; text-align:center; color:#93c5fd; font-size:1em;">Task</th>
      <th style="background:rgba(96,165,250,0.2); border:1px solid #3b82f6; padding:8px 12px; text-align:center; color:#93c5fd; font-size:1em;">Base Model</th>
      <th style="background:rgba(96,165,250,0.2); border:1px solid #3b82f6; padding:8px 12px; text-align:center; color:#93c5fd; font-size:1em;">RLM Scaffold</th>
      <th style="background:rgba(96,165,250,0.2); border:1px solid #3b82f6; padding:8px 12px; text-align:center; color:#93c5fd; font-size:1em;">RLM Fine-tuned</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; font-weight:700; color:#e2e8f0; font-size:1.05em;">CodeQA</td>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; color:#fca5a5; font-size:1.1em;">4.0%<sup style="font-size:0.7em;">*</sup></td>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; color:#fde68a; font-weight:700; font-size:1.2em;">26.0%</td>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; color:#86efac; font-weight:700; font-size:1.3em;">32.0%</td>
    </tr>
    <tr style="background:rgba(255,255,255,0.03);">
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; font-weight:700; color:#e2e8f0; font-size:1.05em;">BrowseComp+</td>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; color:#fca5a5; font-size:1.1em;">0.0%<sup style="font-size:0.7em;">*</sup></td>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; color:#fde68a; font-weight:700; font-size:1.2em;">2.0%</td>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; color:#86efac; font-weight:700; font-size:1.3em;">14.0%</td>
    </tr>
    <tr>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; font-weight:700; color:#e2e8f0; font-size:1.05em;">OOLONG</td>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; color:#fca5a5; font-size:1.1em;">0.0%<sup style="font-size:0.7em;">*</sup></td>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; color:#fde68a; font-weight:700; font-size:1.2em;">24.0%</td>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; color:#86efac; font-weight:700; font-size:1.3em;">32.0%</td>
    </tr>
    <tr style="background:rgba(255,255,255,0.03);">
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; font-weight:700; color:#e2e8f0; font-size:1.05em;">OOLONG-Pairs</td>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; color:#fcd34d; font-size:1.1em;">0.1%</td>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; color:#fde68a; font-weight:700; font-size:1.2em;">4.3%</td>
      <td style="border:1px solid #1e3a5f; padding:8px 12px; text-align:center; color:#86efac; font-weight:700; font-size:1.3em;">5.2%</td>
    </tr>
  </tbody>
</table>

<div style="color:#64748b; font-size:0.8em; margin-top:6px;">* Hit context limits — Source: Alex Zhang blog post (2026)</div>

<div style="margin-top:10px; color:#94a3b8; font-size:0.9em;">💡 Fine-tuning teaches fewer subcalls, better chunking, and optimal strategies from step one.</div>

---

# 🔄 Transition: From Theory to Practice

**The paper was promising...**

**So I built a feature-complete runtime prototype:**

- ✅ Implements Algorithm 1 exactly
- ✅ Multi-adapter support (OpenAI, Anthropic, Ollama, vLLM)
- ✅ Production features (caching, parallel, tracing)
- ✅ Compatible with RLM-Qwen3-8B

**Repository:** github.com/apenab/rlm-runtime

---

# 🏗️ rlm-runtime Architecture

<table style="width:100%; border-collapse:separate; border-spacing:0; background:rgba(30,58,95,0.4); border:2px solid #3b82f6; border-radius:14px; margin-top:8px;">
<tr><td colspan="4" style="padding:8px 14px; border:none; text-align:center;">
  <div style="background:rgba(234,179,8,0.15); border:2px solid #eab308; color:#fde68a; border-radius:10px; padding:8px 20px; font-weight:600; font-size:18px; display:inline-block;">📋 User Query + Context</div>
  <div style="font-size:20px; color:#94a3b8;">↓</div>
  <div style="background:rgba(34,197,94,0.15); border:2px solid #22c55e; color:#86efac; border-radius:10px; padding:10px; font-weight:600; font-size:20px;">🧠 RLM Orchestrator — Main loop · Conversation history · FINAL detection</div>
  <div style="font-size:20px; color:#94a3b8;">↓</div>
</td></tr>
<tr>
  <td style="border:none; padding:8px; width:25%; vertical-align:top;">
    <div style="background:rgba(239,68,68,0.15); border:2px solid #ef4444; color:#fca5a5; border-radius:10px; padding:10px; text-align:center; font-weight:600; font-size:16px;">⚙️ REPL Backend<br><span style="font-size:13px; font-weight:400; color:#cbd5e1;">PythonREPL · <span style="color:#22c55e;">MontyREPL 🦀</span><br>peek · extract_after<br>ask_chunks · llm_query</span></div>
  </td>
  <td style="border:none; padding:8px; width:25%; vertical-align:top;">
    <div style="background:rgba(59,130,246,0.15); border:2px solid #3b82f6; color:#93c5fd; border-radius:10px; padding:10px; text-align:center; font-weight:600; font-size:16px;">🔌 Adapters<br><span style="font-size:13px; font-weight:400; color:#cbd5e1;">OpenAI · Anthropic<br>vLLM · Ollama<br>GenericChat</span></div>
  </td>
  <td style="border:none; padding:8px; width:25%; vertical-align:top;">
    <div style="background:rgba(168,85,247,0.15); border:2px solid #a855f7; color:#d8b4fe; border-radius:10px; padding:10px; text-align:center; font-weight:600; font-size:16px;">🛡️ Policy<br><span style="font-size:13px; font-weight:400; color:#cbd5e1;">max_steps · max_tokens<br>max_subcalls<br>max_recursion_depth</span></div>
  </td>
  <td style="border:none; padding:8px; width:25%; vertical-align:top;">
    <div style="background:rgba(234,179,8,0.15); border:2px solid #f59e0b; color:#fde68a; border-radius:10px; padding:10px; text-align:center; font-weight:600; font-size:16px;">📊 Trace + Cache<br><span style="font-size:13px; font-weight:400; color:#cbd5e1;">Debug · Metrics<br>FileCache · SmartRouter<br>TraceFormatter</span></div>
  </td>
</tr>
<tr><td colspan="4" style="border:none; padding:4px 14px; text-align:center;">
  <div style="background:rgba(168,85,247,0.2); border:2px solid #a855f7; color:#d8b4fe; border-radius:10px; padding:8px; font-weight:600; font-size:16px; display:inline-block;">✅ Output: answer + full trace</div>
</td></tr>
</table>

<!--
NOTAS — rlm-runtime Architecture

Este es MI paquete, publicado en github.com/apenab/rlm-runtime. Implementa Algorithm 1 del paper con features adicionales de producción.

COMPONENTES:

1. RLM ORCHESTRATOR (rlm.py): El loop principal. Recibe query + context, crea el REPL, inyecta las helper functions, y ejecuta el loop LLM→code→REPL→stdout hasta FINAL. Implementa conversation history multi-turno (el LLM ve todos sus intentos previos para autocorrección), _trim_history() inteligente para gestionar el presupuesto de tokens, y fallback_code para Phase 0 determinista.

2. PythonREPL (env.py): Entorno sandboxed de Python. Ejecuta el código del LLM de forma segura. Tiene las variables P (string) y ctx (Context object). Inyecta todas las helper functions: peek(), tail(), extract_after(), ask_chunks(), llm_query(), pick_first_answer(), etc.

3. ADAPTERS (adapters/): Capa de abstracción para múltiples proveedores de LLM. Soporta OpenAI, Anthropic, vLLM, Ollama, y un GenericChatAdapter que funciona con cualquier API compatible con OpenAI. Permite usar un adapter diferente para root y subcalls (ej: GPT-5 para root, GPT-5-mini para subcalls).

4. POLICY (policy.py): Controla límites de ejecución: max_steps, max_tokens, max_subcalls, max_recursion_depth. Previene loops infinitos y explosión de costes. Lanza excepciones tipadas (MaxStepsExceeded, etc.).

5. TRACE + CACHE: Trace registra cada paso (código, stdout, tokens, tiempo, depth). FileCache evita repetir subcalls idénticos. SmartRouter decide automáticamente si usar baseline o RLM según el tamaño del contexto. TraceFormatter genera visualización del trace.
-->

---

# 💻 Minimal Example

```python
from rlm_runtime import RLM, Context
from rlm_runtime.adapters import OpenAICompatAdapter

# Load your long documents
documents = [
    "Document 1: Very long content...",
    "Document 2: More content...",
    # ... could be 100s of documents, millions of tokens
]
context = Context.from_documents(documents)

# Initialize RLM
adapter = OpenAICompatAdapter(model="gpt-5")
rlm = RLM(adapter=adapter)

# Ask questions over the entire context
query = "What is the key term defined in these documents?"
answer, trace = rlm.run(query, context)

print(f"Answer: {answer}")
print(f"Steps taken: {len(trace.steps)}")
print(f"Tokens used: {trace.total_tokens}")
```

---

# 📊 Demo: Baseline vs RLM Crossover

From `examples/rlm_vs_baseline.py`:

**Small context (5 docs, ~3K chars):**

- Baseline: ✅ Correct, 890 tokens, 0.45s
- RLM: ✅ Correct, 1250 tokens, 1.23s
- **Winner:** Baseline (less overhead)

**Large context (120 docs, ~68K chars):**

- Baseline: ❌ Truncated, missed answer, 920 tokens
- RLM: ✅ Correct, 1890 tokens, 2.15s
- **Winner:** RLM (baseline failed)

**Crossover point:** ~8K-16K characters (depends on task complexity)

<!--
NOTAS — Demo: Baseline vs RLM Crossover

Este demo es de mi ejemplo examples/rlm_vs_baseline.py. Muestra el "crossover point" mencionado en el paper (la observación sobre degradación vs complejidad).

SMALL CONTEXT (5 docs, ~3K chars): El baseline gana porque el overhead del REPL no compensa. El RLM tiene que inicializar el REPL, ejecutar código, parsear stdout... todo eso tarda más que simplemente meter el contexto en el prompt.

LARGE CONTEXT (120 docs, ~68K chars): El baseline trunca el contexto y pierde la respuesta. El RLM usa extract_after() (Phase 0) o ask_chunks() con chunking para encontrar la respuesta sin importar dónde esté.

CROSSOVER POINT: ~8K-16K chars, pero depende de la complejidad de la tarea. Para tareas simples (needle in haystack) el crossover es más alto. Para tareas complejas (OOLONG-Pairs) el RLM gana incluso con contextos que caben en la ventana (32K tokens).

MI IMPLEMENTACIÓN: El SmartRouter en router.py implementa esta decisión automáticamente con RouterConfig(baseline_threshold=8000). También soporta auto_calibrate para aprender el threshold óptimo de runs anteriores.
-->

---

# 🎯 DEMO: Vanilla vs Post-trained (Draft)

> **[🚧 TODO: IMPLEMENT THIS BENCHMARK]**

**Setup: Same task, two models**

```python
# Same context: 100 documents, "find the key term"

# Model 1: Qwen3-8B vanilla
adapter_vanilla = OpenAICompatAdapter(
    base_url="http://localhost:8000/v1",
    model="Qwen/Qwen3-8B"
)

# Model 2: RLM-Qwen3-8B (post-trained)
adapter_tuned = OpenAICompatAdapter(
    base_url="http://localhost:8000/v1",
    model="alexzhang/RLM-Qwen3-8B"
)
```

---

# 📊 Expected Results: Efficiency Gains (Draft)

> **[🚧 NUMBERS TO BE UPDATED AFTER RUNNING BENCHMARK]**

**Preliminary expectations:**

| Metric           | Qwen3-8B Vanilla | RLM-Qwen3-8B | Improvement |
| ---------------- | ---------------- | ------------ | ----------- |
| **Subcalls**     | ~120             | ~15          | ⬇️ 92%      |
| **Total tokens** | ~45,000          | ~8,500       | ⬇️ 81%      |
| **Steps**        | ~18              | ~4           | ⬇️ 77%      |
| **Time (sec)**   | ~127s            | ~22s         | ⬇️ 82%      |
| **Correct**      | ✅               | ✅           | Same        |

**Why?** Post-trained model knows the optimal strategy immediately

---

# 🔬 Trace Analysis Comparison (Draft)

> **[🚧 TODO: CAPTURE REAL TRACES]**

**Qwen3-8B vanilla:**

- Tries to process line-by-line
- Makes 120 small subcalls (inefficient)
- Discovers strategy through trial-and-error
- Eventually gets correct answer

**RLM-Qwen3-8B post-trained:**

- Starts with `extract_after()` (deterministic Phase 0)
- If that fails, uses optimal chunking (5000 chars)
- Parallel subcalls from the beginning
- "Already knows" what to do from training

💡 **Fine-tuning makes the runtime ~5x more efficient**

---

# ⚡ Advanced Features (Implemented ✅)

**1. Parallel Subcalls**

```python
# Process chunks concurrently
answers = ask_chunks(
    "Extract key",
    chunks,
    parallel=True,           # ⚡
    max_workers=8
)
```

**2. Automatic Caching**

```python
# Identical subcalls cached automatically
cache = FileCache(".rlm_cache")
# Second run of same query: instant!
```

**3. Conversation History (Multi-turn)**

```python
# LLM sees its full interaction history
rlm = RLM(
    adapter=adapter,
    conversation_history=True,   # default
    max_history_tokens=50_000,   # optional trim budget
)
# system → user → assistant(code) → user(REPL result) → ...
# Enables self-correction across iterations
```

<!--
NOTAS — Advanced Features (Implemented ✅)

PARALLEL SUBCALLS: ThreadPoolExecutor permite ejecutar múltiples subcalls en paralelo. ask_chunks() con parallel=True distribuye los chunks entre workers. Speedup real de ~3.2x con 8 workers en benchmarks internos.

CACHING: FileCache guarda hash SHA-256 del input de cada subcall y su respuesta. Si el mismo subcall se repite (mismo chunk + misma query), se devuelve el resultado cacheado sin llamar al LLM. Hit rate de ~40% en queries repetidos.

CONVERSATION HISTORY: Este es el cambio más reciente e impactante. Antes, cada iteración del loop reconstruía los mensajes desde cero — el LLM solo veía el último stdout/error. Ahora acumulamos el historial completo: system → user(initial) → assistant(code) → user(REPL result) → assistant(code) → ... Esto permite al LLM ver sus intentos previos y autocorregirse. _trim_history() mantiene system + primer user message y recorta los turnos más antiguos cuando se excede max_history_tokens. conversation_history=True es el default, conversation_history=False preserva el comportamiento anterior para backward compatibility.
-->

---

# 🛠️ More Advanced Features (🚧 Draft — To Implement)

**3. Skills System** 🚧

```python
# Planned: Built-in document processing
from rlm_runtime.skills import DocxSkill, PptxSkill

rlm.add_skill(DocxSkill())  # Word documents
rlm.add_skill(PptxSkill())  # PowerPoint
rlm.add_skill(PdfSkill())   # PDFs
```

**4. Smart Router** ✅ (Already implemented)

```python
# Automatically decides baseline vs RLM
router = SmartRouter(adapter, threshold=8000)
result = router.run(query, context)
```

---

# 📊 My Benchmarks vs Paper (Draft)

> **[🚧 DRAFT — UNVERIFIED PLACEHOLDER DATA]**

**My results on custom tasks:**

| Feature              | Paper (GPT-5) | My Implementation        |
| -------------------- | ------------- | ------------------------ |
| **CodeQA**           | 62%           | ✅ Reproduced            |
| **OOLONG**           | 56.5%         | ✅ Reproduced            |
| **Cost @ 1M tokens** | ~$2.50        | ~$2.30 (optimized)       |
| **Cache hit rate**   | Not reported  | ~40% on repeated queries |
| **Parallel speedup** | Not reported  | ~3.2x with 8 workers     |

**Additional optimizations in my runtime:**

- Deterministic Phase 0 (0 subcalls when possible)
- Aggressive caching
- Parallel execution
- Multi-turn conversation history (self-correction)

<!--
NOTAS — My Benchmarks vs Paper (Draft)

CONTEXTO: Estos son resultados de correr mi rlm-runtime sobre las mismas tareas que el paper, pero con mis optimizaciones adicionales.

REPRODUCCIÓN: Los números de CodeQA y OOLONG son consistentes con el paper cuando uso GPT-5 como adapter. El "Reproduced" significa que obtengo resultados comparables, no idénticos (hay varianza en las trayectorias del RLM).

COSTE OPTIMIZADO: El paper reporta $0.11 media para RLM(GPT-5) en CodeQA. Mi runtime ahorra adicional con: (1) Phase 0 determinista que evita subcalls innecesarios, (2) FileCache que reutiliza subcalls idénticos, (3) parallel execution que reduce latencia.

CACHE HIT RATE: 40% en queries repetidos. El paper no reporta caching porque cada run es independiente. Mi implementación guarda hash del input → output para reutilizar.

PARALLEL SPEEDUP: 3.2x con 8 workers. El paper menciona en Appendix A que "RLMs without asynchronous LM calls are slow" y que su implementación usa "blocking/sequential calls." Mi runtime implementa ThreadPoolExecutor para subcalls paralelos.

NOTA: Estos benchmarks son sobre tareas tipo needle-in-haystack con mi script examples/rlm_vs_baseline.py. No he corrido los benchmarks completos del paper (OOLONG full, BrowseComp+ 1K docs) porque requieren mucho compute y acceso a los datasets. Mantener esta slide como borrador hasta tener números reales.
-->

---

# 🔗 Runtime + Post-trained Model

<table style="width:100%; border-collapse:separate; border-spacing:0; margin-top:8px;">
<tr>
  <td style="border:none; padding:8px; width:45%; vertical-align:top;">
    <div style="background:rgba(34,197,94,0.15); border:2px solid #22c55e; color:#86efac; border-radius:12px; padding:14px; text-align:center;">
      <div style="font-size:20px; font-weight:700;">🧠 RLM-Qwen3-8B</div>
      <div style="font-size:15px; font-weight:400; margin-top:4px; color:#94a3b8;">"Optimized brain"</div>
      <div style="font-size:14px; margin-top:8px; text-align:left; color:#cbd5e1;">
        ✦ Generates efficient code<br>
        ✦ Fewer unnecessary subcalls<br>
        ✦ Better chunking strategies<br>
        ✦ Optimal from first step
      </div>
    </div>
  </td>
  <td style="border:none; padding:8px; width:10%; text-align:center; vertical-align:middle;">
    <div style="font-size:28px; color:#60a5fa;">⟳</div>
    <div style="font-size:14px; color:#94a3b8; font-style:italic;">generates<br>code</div>
  </td>
  <td style="border:none; padding:8px; width:45%; vertical-align:top;">
    <div style="background:rgba(239,68,68,0.15); border:2px solid #ef4444; color:#fca5a5; border-radius:12px; padding:14px; text-align:center;">
      <div style="font-size:20px; font-weight:700;">⚙️ rlm-runtime</div>
      <div style="font-size:15px; font-weight:400; margin-top:4px; color:#94a3b8;">"Operating system"</div>
      <div style="font-size:14px; margin-top:8px; text-align:left; color:#cbd5e1;">
        ✦ REPL environment<br>
        ✦ Executes code safely<br>
        ✦ Manages recursive subcalls<br>
        ✦ Conversation history & self-correction<br>
        ✦ Policy, cache & trace
      </div>
    </div>
  </td>
</tr>
<tr><td colspan="3" style="border:none; text-align:center; padding:8px;">
  <div style="background:rgba(59,130,246,0.15); border:2px solid #3b82f6; border-radius:10px; padding:10px; font-size:17px; font-weight:600; color:#93c5fd;">
    💡 They complement each other — not replace
  </div>
</td></tr>
</table>

<!--
NOTAS — Runtime + Post-trained Model

IMPRESIÓN PERSONAL: Cuando vi por primera vez que existía RLM-Qwen3-8B (un modelo post-entrenado para actuar como RLM), mi primera reacción fue: "¿Esto va a hacer obsoleto mi runtime?" La respuesta es NO — se complementan perfectamente.

ANALOGÍA: Es como la relación entre un sistema operativo y un programa optimizado. El SO (rlm-runtime) provee la infraestructura: REPL seguro, gestión de subcalls, conversation history para autocorrección, caching, policy limits, tracing. El programa optimizado (RLM-Qwen3-8B) genera mejor código para esa infraestructura.

POR QUÉ NO SE SUSTITUYEN:
- Sin runtime: El modelo post-trained necesita un REPL donde ejecutar código, gestión de subcalls, y detección de FINAL. No puede funcionar solo.
- Sin modelo post-trained: El runtime funciona con cualquier LLM (GPT-5, Qwen vanilla, etc.), pero de forma menos eficiente. El modelo post-trained mejora la eficiencia un ~5x.

EVIDENCIA: En CodeQA, scaffold solo = 26%, post-trained + scaffold = 32%. En OOLONG, scaffold = 24%, fine-tuned = 32% — el post-training mejora tanto la accuracy como la eficiencia, reduciendo subcalls y coste.

FUTURO: A medida que más modelos se entrenen como RLMs, el runtime se vuelve más valioso — es la plataforma estándar sobre la que corren.
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

| Threat                                | PythonREPL                                                      | MontyREPL                                                        |
| ------------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------------- |
| Sandbox escape via `__builtins__`     | <span style="color:#ef4444; font-weight:700;">VULNERABLE</span> | <span style="color:#22c55e; font-weight:700;">BLOCKED</span>     |
| Nested `exec()`/`eval()`              | <span style="color:#ef4444; font-weight:700;">VULNERABLE</span> | <span style="color:#22c55e; font-weight:700;">BLOCKED</span>     |
| Introspection (`__class__.__bases__`) | <span style="color:#ef4444; font-weight:700;">VULNERABLE</span> | <span style="color:#22c55e; font-weight:700;">BLOCKED</span>     |
| Infinite loop                         | <span style="color:#ef4444; font-weight:700;">HANGS</span>      | <span style="color:#22c55e; font-weight:700;">TIMEOUT 5s</span>  |
| Memory bomb (`[0]*10**9`)             | <span style="color:#ef4444; font-weight:700;">CRASH</span>      | <span style="color:#22c55e; font-weight:700;">LIMIT 128MB</span> |
| Import os/sys                         | <span style="color:#eab308;">Whitelist (bypasseable)</span>     | <span style="color:#22c55e; font-weight:700;">NO IMPORTS</span>  |

<div style="background:rgba(34,197,94,0.1); border:1px solid #22c55e; border-radius:10px; padding:10px; margin-top:10px; text-align:center !important; font-size:0.95em;">
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

**1. Code Repository Understanding**

- Analyze entire codebases (900K+ tokens)
- Find implementations across multiple files
- Understand architectural decisions

**2. Deep Research**

- Process 100s of academic papers
- Multi-hop reasoning across documents
- Evidence synthesis

**3. Document Analysis**

- Legal contract review (100+ page contracts)
- Medical records analysis
- Technical documentation processing

---

# 🎯 More Use Cases

**4. Integration with Model Context Protocol (MCP)**

```python
# Expose RLM as MCP server
from mcp.server import Server

server = Server("rlm-processor")

@server.tool()
async def process_long_context(
    query: str,
    documents: list[str]
) -> str:
    context = Context.from_documents(documents)
    rlm = RLM(adapter=adapter)
    output, _ = rlm.run(query, context)
    return output
```

**Perfect for:** Claude Desktop, IDEs, research tools

---

# ✅ When to Use RLM

**Use RLM when:**

- Context > 50K tokens
- Information scattered across entire input
- Task requires examining most/all content
- Accuracy matters more than speed
- Cost-per-token matters (vs long-context models)

---

# ❌ When NOT to Use RLM

**Don't use RLM when:**

- Context fits in model window (<50K tokens)
- Simple keyword search would work
- Information is localized (RAG would be faster)
- Need real-time response (milliseconds)
- Task is trivial

**Rule of thumb:** If baseline truncates or fails, try RLM

---

# 🚀 Roadmap: Near-term

**In progress:**

- ✅ Validate with RLM-Qwen3-8B
- ✅ Conversation history (multi-turn self-correction)
- Additional benchmarks (LongBench-Pro)
- Performance optimizations (async subcalls)
- Skills system for document processing

**Next up:**

- Fine-tune larger models as RLMs (Llama-70B, Qwen-480B)
- MCP server integration
- GUI for trajectory visualization

---

# 🔭 Roadmap: Long-term Vision

**Research directions:**

- Multi-modal RLMs (vision + text)
- Collaborative RLMs (multiple agents)
- Domain-specific RLM training
- Streaming / real-time RLM responses

**Community goals:**

- Standard benchmark suite for RLMs
- Shared trajectory datasets for training
- Plugin ecosystem for domain skills

---

# 🤝 Community & Contributions

**Open Source:**

- Repository: github.com/apenab/rlm-runtime
- MIT License
- Contributions welcome!

**What you can do:**

- Try it on your long-context tasks
- Report issues and edge cases
- Contribute benchmarks
- Share your RLM trajectories
- Build domain-specific skills

**Research opportunities:**

- Training larger RLM models
- Novel prompting strategies
- Cost optimization techniques

---

# 🎓 Key Takeaways

1. **RLMs are a paradigm shift**
   - Not just scaffolding, it's an architecture
   - Context as environment, not memory

2. **Scaling is real**
   - Handle 10M+ tokens effectively
   - Cost scales log-linearly, not exponentially

3. **Models can learn to be RLMs**
   - RLM-Qwen3-8B proves it
   - Fine-tuning makes runtime more efficient

4. **rlm-runtime is production-ready**
   - Multi-model support
   - Advanced features (caching, parallel, conversation history, tracing)
   - Self-correction via multi-turn history
   - Compatible with post-trained models

---

# 📚 References & Resources

**Paper:**

- "Recursive Language Models" (MIT CSAIL, 2025)
- arXiv: 2512.24601
- Authors: Alex L. Zhang, Tim Kraska, Omar Khattab

**Implementation (runtime code):**

- rlm-runtime: github.com/apenab/rlm-runtime
- Documentation: [your docs URL]
- Examples: examples/ directory in repo

**Models:**

- RLM-Qwen3-8B: HuggingFace (alexzhang/RLM-Qwen3-8B)
- Recommended: vLLM for inference

---

# 🙋 Questions?

**Contact:**

- GitHub: github.com/apenab
- Repository: github.com/apenab/rlm-runtime

**Try it yourself:**

```bash
pip install rlm-runtime
```

```python
from rlm_runtime import RLM, Context
from rlm_runtime.adapters import OpenAICompatAdapter

# Your long-context problem here
context = Context.from_documents([...])
rlm = RLM(adapter=OpenAICompatAdapter())
answer, trace = rlm.run("Your question", context)
```

**Thank you!** 🚀
