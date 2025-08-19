#!/bin/bash

# Setup Git script

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

print_step "Setting up Git repository..."

# Check if git is available
if ! command -v git &> /dev/null; then
    print_error "Git is not installed"
    exit 1
fi

# Initialize git repository if not already initialized
if [[ ! -d ".git" ]]; then
    print_step "Initializing Git repository..."
    git init
    print_success "Git repository initialized"
else
    print_warning "Git repository already exists"
fi

# Add .gitignore if not already tracked
if [[ -f ".gitignore" ]] && ! git ls-files --error-unmatch .gitignore &> /dev/null; then
    git add .gitignore
    print_success "Added .gitignore to Git"
fi

# Install pre-commit hooks if pre-commit is available
if command -v pre-commit &> /dev/null; then
    print_step "Installing pre-commit hooks..."
    if pre-commit install; then
        print_success "Pre-commit hooks installed"
    else
        print_warning "Failed to install pre-commit hooks"
    fi
else
    print_warning "pre-commit not available, skipping hook installation"
fi

# Check if there are any files to commit
if git status --porcelain | grep -q .; then
    print_step "Adding files to Git..."
    git add .
    
    # Create initial commit if no commits exist
    if ! git rev-parse HEAD &> /dev/null; then
        print_step "Creating initial commit..."
        git commit -m "Initial commit: Python project setup

- Added project structure
- Configured Ruff for linting and formatting
- Added pytest for testing
- Set up pre-commit hooks
- Added VSCode configuration
- Created development dependencies"
        print_success "Initial commit created"
    else
        print_warning "Files staged but not committed (existing repository)"
        print_color "Run 'git commit -m \"your message\"' to commit changes" "$YELLOW"
    fi
else
    print_success "No changes to commit"
fi

# Show git status
print_step "Git status:"
git status --short

print_success "Git setup complete"