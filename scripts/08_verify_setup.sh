#!/bin/bash

# Verify setup script

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

print_step "Verifying project setup..."

verification_errors=0

# Check if virtual environment exists and is activated
if [[ -d ".venv" ]]; then
    print_success "Virtual environment exists"
    
    # Try to activate and check Python
    if [[ -f ".venv/bin/activate" ]]; then
        source .venv/bin/activate
    elif [[ -f ".venv/Scripts/activate" ]]; then
        source .venv/Scripts/activate
    fi
    
    if python --version &> /dev/null; then
        python_version=$(python --version)
        print_success "Python available: $python_version"
    else
        print_error "Python not accessible in virtual environment"
        ((verification_errors++))
    fi
else
    print_warning "Virtual environment not found"
fi

# Check required files exist
required_files=(
    "pyproject.toml"
    "Makefile"
    ".gitignore"
    "README.md"
    ".vscode/settings.json"
    ".pre-commit-config.yaml"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        print_success "✓ $file exists"
    else
        print_error "✗ $file missing"
        ((verification_errors++))
    fi
done

# Check directory structure
required_dirs=(
    "src"
    "tests"
    "docs"
    ".vscode"
    ".github/workflows"
)

for dir in "${required_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        print_success "✓ $dir/ directory exists"
    else
        print_error "✗ $dir/ directory missing"
        ((verification_errors++))
    fi
done

# Test Python imports and tools
print_step "Testing Python tools..."

# Test ruff
if command -v ruff &> /dev/null; then
    print_success "✓ Ruff available"
    
    # Test ruff check
    if ruff check . --quiet; then
        print_success "✓ Ruff check passed"
    else
        print_warning "⚠️  Ruff found issues (this is normal for new projects)"
    fi
    
    # Test ruff format check
    if ruff format --check . &> /dev/null; then
        print_success "✓ Code formatting is correct"
    else
        print_warning "⚠️  Code needs formatting"
    fi
else
    print_error "✗ Ruff not available"
    ((verification_errors++))
fi

# Test pytest
if command -v pytest &> /dev/null; then
    print_success "✓ Pytest available"
    
    # Run tests if they exist
    if [[ -f "tests/test_example.py" ]]; then
        print_step "Running example tests..."
        if pytest tests/test_example.py -v; then
            print_success "✓ Tests passed"
        else
            print_error "✗ Tests failed"
            ((verification_errors++))
        fi
    fi
else
    print_error "✗ Pytest not available"
    ((verification_errors++))
fi

# Test pre-commit if available
if command -v pre-commit &> /dev/null; then
    print_success "✓ Pre-commit available"
    
    # Check if hooks are installed
    if pre-commit run --all-files &> /dev/null; then
        print_success "✓ Pre-commit hooks working"
    else
        print_warning "⚠️  Pre-commit hooks need attention"
    fi
else
    print_warning "Pre-commit not available (optional)"
fi

# Test Git setup
if [[ -d ".git" ]]; then
    print_success "✓ Git repository initialized"
    
    # Check git status
    if git status &> /dev/null; then
        print_success "✓ Git working properly"
    else
        print_error "✗ Git repository has issues"
        ((verification_errors++))
    fi
else
    print_warning "Git repository not initialized"
fi

# Test VSCode setup
if command -v code &> /dev/null; then
    print_success "✓ VSCode CLI available"
else
    print_warning "VSCode CLI not available (optional)"
fi

# Check if essential Python packages are available
essential_packages=("ruff" "pytest" "pre_commit")
for package in "${essential_packages[@]}"; do
    if python -c "import $package" 2>/dev/null; then
        print_success "✓ Python package '$package' importable"
    else
        print_error "✗ Python package '$package' not available"
        ((verification_errors++))
    fi
done

# Summary
print_step "Verification Summary:"
if [[ $verification_errors -eq 0 ]]; then
    print_success "🎉 All verifications passed! Project setup is complete."
else
    print_error "❌ $verification_errors verification(s) failed."
    print_warning "Please check the errors above and re-run the setup if needed."
fi

exit $verification_errors