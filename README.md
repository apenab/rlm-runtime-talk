# 🧠 Recursive Language Models: From Theory to Practice

A comprehensive 30-minute technical presentation about Recursive Language Models (RLMs) and the `rlm-runtime` implementation.

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
Visit: <https://apenab.github.io/rlm-presentation/>

**Option 2: Download PDF**
[Download PDF](./presentation.pdf)

**Option 3: Local Preview**

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

## 📦 Repository Contents

```
rlm-presentation/
├── rlm-presentation.md    # Main presentation (Marp format)
├── README.md              # This file
├── index.html             # Generated HTML presentation
├── presentation.pdf       # Generated PDF version
├── assets/                # Images and diagrams
│   ├── algorithm1.png
│   ├── algorithm2.png
│   └── benchmark-graph.png
└── .github/
    └── workflows/
        └── build.yml      # Auto-generate on push
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

- **Repository:** [alexzhang13/rlm-runtime](https://github.com/alexzhang13/rlm-runtime)
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
- **rlm-runtime:** <https://github.com/alexzhang13/rlm-runtime>
- **Author's Blog:** <https://alexzhang13.github.io/blog/2025/rlm/>
- **Presentation Repo:** <https://github.com/apenab/rlm-presentation>

## 📧 Contact

Questions about the presentation or RLMs?

- **GitHub Issues:** [Open an issue](https://github.com/apenab/rlm-presentation/issues)
- **Original Author:** [@alexzhang13](https://github.com/alexzhang13)

---

**Built with [Marp](https://marp.app/)** - Markdown Presentation Ecosystem
