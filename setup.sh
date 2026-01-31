#!/bin/bash
# Quick setup script for RLM presentation repository

set -e

echo "🚀 RLM Presentation Repository Setup"
echo "======================================"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install git first."
    exit 1
fi

# Get GitHub username
read -p "Enter your GitHub username: " GITHUB_USER

# Get repository name (default: rlm-presentation)
read -p "Repository name [rlm-presentation]: " REPO_NAME
REPO_NAME=${REPO_NAME:-rlm-presentation}

echo ""
echo "Setting up repository: $GITHUB_USER/$REPO_NAME"
echo ""

# Create directory structure
mkdir -p .github/workflows
mkdir -p assets

echo "✅ Created directory structure"

# Update README.md with username
sed -i.bak "s/\[your-username\]/$GITHUB_USER/g" README.md
rm README.md.bak 2>/dev/null || true

echo "✅ Updated README.md with your username"

# Update package.json
sed -i.bak "s/\[your-username\]/$GITHUB_USER/g" package.json
rm package.json.bak 2>/dev/null || true

echo "✅ Updated package.json"

# Rename workflow file to correct location
if [ -f ".github-workflows-build.yml" ]; then
    mv .github-workflows-build.yml .github/workflows/build.yml
    echo "✅ Moved GitHub Actions workflow to correct location"
fi

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    git init
    echo "✅ Initialized git repository"
fi

# Add all files
git add .

# Initial commit
git commit -m "Initial commit: RLM presentation with auto-build" 2>/dev/null || {
    echo "⚠️  Git commit failed. You might need to configure git:"
    echo "   git config --global user.name 'Your Name'"
    echo "   git config --global user.email 'your.email@example.com'"
}

# Add remote
git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git" 2>/dev/null || {
    echo "ℹ️  Remote 'origin' already exists"
}

# Set main branch
git branch -M main

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Create the repository on GitHub:"
echo "   https://github.com/new"
echo ""
echo "2. Push your code:"
echo "   git push -u origin main"
echo ""
echo "3. Enable GitHub Pages in repository Settings > Pages"
echo ""
echo "4. Your presentation will be available at:"
echo "   https://$GITHUB_USER.github.io/$REPO_NAME/"
echo ""
echo "📖 See SETUP-INSTRUCTIONS.md for detailed steps"
