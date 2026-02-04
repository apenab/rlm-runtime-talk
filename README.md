# 🧠 Recursive Language Models: From Theory to Practice
Rethinking how LLMs handle long contexts

CFP:
Los modelos de lenguaje actuales muestran una degradación severa de calidad a medida que crece el tamaño y la complejidad de la información de entrada, un fenómeno conocido como context rot. Este límite no se debe únicamente al tamaño de la ventana de contexto, sino a una restricción más profunda: los LLMs están obligados a manipular cadenas largas exclusivamente dentro de su espacio de tokens, donde la atención y la memoria no escalan.

En esta charla presento Recursive Language Models (RLMs), un paradigma general de inferencia propuesto por MIT CSAIL que replantea el problema del contexto como un problema de sistemas. En lugar de introducir el prompt completo en la ventana del modelo, los RLMs lo colocan en un entorno externo persistente, accesible mediante un REPL, y permiten que el propio LLM genere código para inspeccionar, filtrar, descomponer y procesar ese contexto mediante llamadas recursivas a otros modelos. En benchmarks como CodeQA y BrowseComp+, los RLMs alcanzan hasta un 91 % de precisión donde los enfoques tradicionales fallan por completo.

Los RLMs escalan el contexto efectivo en órdenes de magnitud sin depender de arquitecturas de contexto largo, y muestran cómo el entrenamiento de modelos nativamente recursivos (como RLM-Qwen3-8B) puede convertirse en un nuevo eje de escala. A lo largo de la charla mostraré cómo funcionan los RLMs, por qué superan a enfoques clásicos como la truncación o la resumización, y cómo implementarlos en la práctica a través de rlm-runtime, un runtime open-source que materializa el paradigma RLM y reproduce los resultados clave del paper.


## 📚 About

This presentation covers:

- **MIT CSAIL Paper** "Recursive Language Models" (arXiv:2512.24601)
- **RLM-Qwen3-8B**: First natively trained RLM model
- **rlm-runtime**: Production-ready implementation
- Benchmarks, use cases, and future directions

## 🎯 Presentation Structure

**Part 1: RLM Fundamentals** (~12 min, 12 slides)

- The problem: Context rot and current solutions
- RLM solution: 3 defining properties
- How it works: Algorithms and examples
- MIT Paper results and benchmarks
- Breakthrough: RLM-Qwen3-8B post-trained model

**Part 2: rlm-runtime Implementation** (~13 min, 13 slides)

- Architecture and components
- Minimal code examples
- Baseline vs RLM comparison
- Vanilla vs Post-trained demo
- Advanced features (caching, parallel, skills)

**Part 3: Applications & Future** (~5 min, 5 slides)

- Real-world use cases
- When to use RLM (decision matrix)
- Roadmap and future work
- Community contributions

## 🚀 Quick Start

### View the Presentation

**Option 1: GitHub Pages (Recommended)**
Visit: <https://apenab.github.io/rlm-runtime-talk/>

**Option 2: Local Preview**

```bash
# Install Marp CLI
npm install -g @marp-team/marp-cli

# Preview in browser
marp -p rlm-presentation.md

# Generate HTML
marp rlm-presentation.md -o index.html

# Generate PDF
marp rlm-presentation.md -o presentation.pdf
```

## 🛠️ Building Locally

### Prerequisites

- Node.js 14+ and npm
- Marp CLI

### Installation

```bash
# Clone the repository
git clone https://github.com/apenab/rlm-runtime-talk.git
cd rlm-presentation

# Install Marp CLI
npm install -g @marp-team/marp-cli
```

### Build Commands

```bash
# Generate HTML (for web hosting)
marp rlm-presentation.md -o index.html

# Generate PDF (for sharing)
marp rlm-presentation.md -o presentation.pdf --allow-local-files

# Generate both
npm run build  # See package.json
```

## 🎨 Customization

### Modify Theme

Edit the `style` section in `rlm-presentation.md`:

```css
style: |
  section {
  font-size: 26px; /* Adjust as needed */
}
h1 {
  color: #2563eb; /* Change title color */
}
```

### Add Images

Place images in `assets/` directory and reference them:

```markdown
![Description](./assets/your-image.png)
```

### Update Content

The presentation is written in Markdown with Marp directives. Each slide is separated by `---`.

## 📖 Key References

### Paper

- **Title:** "Recursive Language Models"
- **Authors:** Alex L. Zhang, Tim Kraska, Omar Khattab (MIT CSAIL)
- **ArXiv:** [2512.24601](https://arxiv.org/abs/2512.24601)
- **Year:** 2025

### Implementation

- **Repository:** [apenab/rlm-runtime](https://github.com/apenab/rlm-runtime)
- **Models:** RLM-Qwen3-8B on HuggingFace
- **Blog:** [alexzhang13.github.io/blog/2025/rlm](https://alexzhang13.github.io/blog/2025/rlm/)

## 🎯 Presentation Tips

**For Presenters:**

- **Part 1 (12 min):** Focus on the "why" - motivation and theory
- **Part 2 (13 min):** Show code examples and live demos
- **Part 3 (5 min):** Inspire audience with applications and future

**Timing Guide:**

- Aim for ~1 minute per slide
- Slides with code: 1.5-2 minutes
- Demo slides: 2-3 minutes
- Q&A: Reserve 5-10 minutes at the end

## 🚧 TODO Items

The presentation includes placeholder sections for:

- [ ] **Slides 19-21:** Vanilla vs Post-trained benchmark results
  - Implement comparison: Qwen3-8B vs RLM-Qwen3-8B
  - Capture real metrics (subcalls, tokens, time)
  - Generate trace visualizations

- [ ] Add your own benchmark numbers
- [ ] Include real trajectory screenshots
- [ ] Add custom diagrams

## 🤝 Contributing

Found an error or want to improve the presentation?

1. Fork this repository
2. Make your changes
3. Submit a Pull Request

**Contribution Areas:**

- [ ] **Slides 19-21:** Vanilla vs Post-trained benchmark results
  - Implement comparison: Qwen3-8B vs RLM-Qwen3-8B
  - Capture real metrics (subcalls, tokens, time)
  - Generate trace visualizations

- [ ] Add your own benchmark numbers
- [ ] Include real trajectory screenshots
- [ ] Add custom diagrams

## 🤝 Contributing

Found an error or want to improve the presentation?

1. Fork this repository
2. Make your changes
3. Submit a Pull Request

**Contribution Areas:**

- Corrections to paper references
- Additional use cases
- Better visualizations
- Code examples
- Benchmark results

## 📄 License

This presentation is licensed under **MIT License**.

The original RLM paper and research belongs to MIT CSAIL authors.

## 🔗 Links

- **Paper:** <https://arxiv.org/abs/2512.24601>
- **rlm-runtime:** <https://github.com/apenab/rlm-runtime>

## 📧 Contact

Questions about the presentation or RLMs?

- **GitHub Issues:** [Open an issue](https://github.com/apenab/rlm-presentation/issues)

---

**Built with [Marp](https://marp.app/)** - Markdown Presentation Ecosystem
