.PHONY: help build preview pdf html install clean

help:
	@echo "RLM Presentation - Available Commands:"
	@echo ""
	@echo "  make install    - Install Marp CLI globally"
	@echo "  make preview    - Live preview in browser"
	@echo "  make build      - Build both HTML and PDF"
	@echo "  make html       - Build HTML only"
	@echo "  make pdf        - Build PDF only"
	@echo "  make clean      - Remove build artifacts"
	@echo ""

install:
	@echo "Installing Marp CLI..."
	npm install -g @marp-team/marp-cli
	@echo "✅ Marp CLI installed"

preview:
	@echo "Starting live preview..."
	@echo "Open your browser at http://localhost:8080"
	marp -p rlm-presentation.md

build: html pdf
	@echo "✅ Build complete: index.html and presentation.pdf"

html:
	@echo "Building HTML presentation..."
	marp rlm-presentation.md -o index.html
	@echo "✅ Generated: index.html"

pdf:
	@echo "Building PDF presentation..."
	marp rlm-presentation.md -o presentation.pdf --allow-local-files
	@echo "✅ Generated: presentation.pdf"

clean:
	@echo "Cleaning build artifacts..."
	rm -f index.html presentation.pdf
	@echo "✅ Cleaned"

watch:
	@echo "Watching for changes..."
	marp -w rlm-presentation.md -o index.html
