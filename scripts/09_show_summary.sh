#!/bin/bash

# Show setup summary script

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_color() { printf "${2}${1}${NC}\n"; }
print_step() { print_color "🔧 $1" "$BLUE"; }
print_success() { print_color "✅ $1" "$GREEN"; }
print_warning() { print_color "⚠️  $1" "$YELLOW"; }
print_error() { print_color "❌ $1" "$RED"; }

PROJECT_NAME="$1"
PYTHON_VERSION="$2"
VENV_TOOL="$3"
CREATE_VENV="$4"

# Get selected venv tool
if [[ -f "/tmp/selected_venv_tool" ]]; then
    SELECTED_TOOL=$(cat /tmp/selected_venv_tool)
    rm -f /tmp/selected_venv_tool  # Clean up temp file
else
    SELECTED_TOOL="$VENV_TOOL"
fi

clear
print_color "
🎉 PYTHON PROJECT SETUP COMPLETE! 🎉
" "$CYAN"

print_color "═══════════════════════════════════════════════════════════════" "$CYAN"
print_color "PROJECT DETAILS" "$MAGENTA"
print_color "═══════════════════════════════════════════════════════════════" "$CYAN"

print_color "📁 Project Name: $PROJECT_NAME" "$BLUE"
print_color "🐍 Python Version: $PYTHON_VERSION" "$BLUE"
if [[ "$CREATE_VENV" == true ]]; then
    print_color "📦 Virtual Environment: $SELECTED_TOOL (.venv/)" "$BLUE"
else
    print_color "📦 Virtual Environment: Not created" "$YELLOW"
fi
print_color "📍 Location: $(pwd)" "$BLUE"

print_color "
═══════════════════════════════════════════════════════════════" "$CYAN"
print_color "WHAT'S INCLUDED" "$MAGENTA"
print_color "═══════════════════════════════════════════════════════════════" "$CYAN"

print_color "🔧 DEVELOPMENT TOOLS:" "$GREEN"
print_color "  ✅ Ruff (linting + formatting)" "$BLUE"
print_color "  ✅ Pytest (testing framework)" "$BLUE"
print_color "  ✅ Pre-commit hooks" "$BLUE"
print_color "  ✅ Coverage reporting" "$BLUE"

print_color "
🏗️  PROJECT STRUCTURE:" "$GREEN"
print_color "  ✅ src/$PROJECT_NAME/ (source code)" "$BLUE"
print_color "  ✅ tests/ (test files)" "$BLUE"
print_color "  ✅ docs/ (documentation)" "$BLUE"
print_color "  ✅ .vscode/ (VSCode configuration)" "$BLUE"
print_color "  ✅ .github/workflows/ (CI/CD)" "$BLUE"

print_color "
📋 CONFIGURATION FILES:" "$GREEN"
print_color "  ✅ pyproject.toml (project metadata + tool config)" "$BLUE"
print_color "  ✅ Makefile (development commands)" "$BLUE"
print_color "  ✅ .gitignore (Git ignore rules)" "$BLUE"
print_color "  ✅ .pre-commit-config.yaml (code quality hooks)" "$BLUE"
print_color "  ✅ .vscode/settings.json (editor configuration)" "$BLUE"

print_color "
═══════════════════════════════════════════════════════════════" "$CYAN"
print_color "QUICK START COMMANDS" "$MAGENTA"
print_color "═══════════════════════════════════════════════════════════════" "$CYAN"

if [[ "$CREATE_VENV" == true ]]; then
    print_color "🚀 ACTIVATE VIRTUAL ENVIRONMENT:" "$GREEN"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        print_color "   .venv\\Scripts\\activate" "$YELLOW"
    else
        print_color "   source .venv/bin/activate" "$YELLOW"
    fi
    print_color ""
fi

print_color "🔨 DEVELOPMENT COMMANDS:" "$GREEN"
print_color "   make help              # Show all available commands" "$YELLOW"
print_color "   make install-dev       # Install development dependencies" "$YELLOW"
print_color "   make test              # Run tests" "$YELLOW"
print_color "   make lint              # Check code quality" "$YELLOW"
print_color "   make fix               # Auto-fix code issues" "$YELLOW"
print_color "   make quality-check     # Run full quality check" "$YELLOW"

print_color "
🎯 VSCODE INTEGRATION:" "$GREEN"
print_color "   code .                 # Open project in VSCode" "$YELLOW"
print_color "   Ctrl+Shift+P → 'Python: Select Interpreter'" "$YELLOW"
print_color "   Select: ./.venv/bin/python" "$YELLOW"

print_color "
📚 GIT WORKFLOW:" "$GREEN"
if [[ -d ".git" ]]; then
    print_color "   git status             # Check repository status" "$YELLOW"
    print_color "   git add .              # Stage changes" "$YELLOW"
    print_color "   git commit -m \"msg\"    # Commit changes" "$YELLOW"
else
    print_color "   git init               # Initialize repository" "$YELLOW"
    print_color "   git add .              # Stage all files" "$YELLOW"
    print_color "   git commit -m \"Initial commit\"" "$YELLOW"
fi

print_color "
═══════════════════════════════════════════════════════════════" "$CYAN"
print_color "NEXT STEPS" "$MAGENTA"
print_color "═══════════════════════════════════════════════════════════════" "$CYAN"

print_color "1. 📖 Read the README.md for detailed instructions" "$BLUE"
print_color "2. 🔧 Start coding in src/$PROJECT_NAME/" "$BLUE"
print_color "3. 🧪 Write tests in tests/" "$BLUE"
print_color "4. 📝 Update pyproject.toml with your project details" "$BLUE"
print_color "5. 🚀 Run 'make quality-check' before committing" "$BLUE"

print_color "
═══════════════════════════════════════════════════════════════" "$CYAN"
print_color "HAPPY CODING! 🐍✨" "$MAGENTA"
print_color "═══════════════════════════════════════════════════════════════" "$CYAN"