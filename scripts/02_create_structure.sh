#!/bin/bash

# Create project structure script

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_color() { printf "${2}${1}${NC}\n"; }
print_step() { print_color "🔧 $1" "$BLUE"; }
print_success() { print_color "✅ $1" "$GREEN"; }
print_warning() { print_color "⚠️  $1" "$YELLOW"; }
print_error() { print_color "❌ $1" "$RED"; }

PROJECT_NAME="$1"
shift

print_step "Creating project structure..."

# Check if --existing flag
existing_project=false
for arg in "$@"; do
    if [[ "$arg" == "--existing" ]]; then
        existing_project=true
        break
    fi
done

# Create project directory if not existing
if [[ "$existing_project" != true ]]; then
    if [[ -d "$PROJECT_NAME" ]]; then
        print_warning "Directory $PROJECT_NAME already exists"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Installation cancelled"
            exit 1
        fi
    else
        mkdir -p "$PROJECT_NAME"
    fi
    cd "$PROJECT_NAME"
fi

# Create directory structure
mkdir -p .vscode
mkdir -p .github/workflows
mkdir -p scripts
mkdir -p src/"$PROJECT_NAME"
mkdir -p tests
mkdir -p docs

# Create basic files
if [[ ! -f "README.md" ]]; then
    cat > README.md << EOF
# $PROJECT_NAME

Python project configured with Ruff for quality analysis and SOLID/KISS principles.

## Installation

\`\`\`bash
make install-dev
\`\`\`

## Usage

\`\`\`bash
make quality-check  # Check code quality
make fix           # Fix issues automatically
make test          # Run tests
make help          # Show all commands
\`\`\`

## Tools included

- ✅ Ruff (linting + formatting)
- ✅ SOLID/KISS analysis
- ✅ Pre-commit hooks
- ✅ VSCode configuration
- ✅ GitHub Actions
EOF
fi

if [[ ! -f ".gitignore" ]]; then
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*.so
.Python
build/
dist/
*.egg-info/
.venv/
.env
.coverage
.pytest_cache/
.ruff_cache/
.DS_Store
.vscode/
.idea/
.claude/
EOF
fi

print_success "Project structure created"