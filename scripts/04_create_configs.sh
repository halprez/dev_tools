#!/bin/bash

# Create configuration files script

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
SETUP_GITHUB_ACTIONS="$2"

print_step "Creating configuration files..."

# Create pyproject.toml
if [[ ! -f "pyproject.toml" ]]; then
    cat > pyproject.toml << EOF
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "$PROJECT_NAME"
version = "0.1.0"
description = "Python project with Ruff and quality tools"
readme = "README.md"
requires-python = ">=3.8"
authors = [
    {name = "Your Name", email = "your.email@example.com"},
]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
dependencies = []

[project.optional-dependencies]
dev = [
    "ruff>=0.1.0",
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "pre-commit>=3.0.0",
]

[project.urls]
Homepage = "https://github.com/yourusername/$PROJECT_NAME"
Repository = "https://github.com/yourusername/$PROJECT_NAME"
Issues = "https://github.com/yourusername/$PROJECT_NAME/issues"

[tool.hatch.build.targets.wheel]
packages = ["src/$PROJECT_NAME"]

[tool.ruff]
target-version = "py38"
line-length = 88
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
    "ARG", # flake8-unused-arguments
    "SIM", # flake8-simplify
    "ICN", # flake8-import-conventions
    "PL",  # pylint
    "RUF", # ruff-specific rules
]
ignore = [
    "E501",   # line too long (handled by formatter)
    "PLR0913", # too many arguments
    "PLR0915", # too many statements
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "auto"

[tool.ruff.per-file-ignores]
"tests/*" = ["PLR2004", "S101", "ARG"]
"__init__.py" = ["F401"]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
addopts = "--cov=src --cov-report=term-missing --cov-report=html"

[tool.coverage.run]
source = ["src"]
omit = ["*/tests/*", "*/test_*"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "if self.debug:",
    "if settings.DEBUG",
    "raise AssertionError",
    "raise NotImplementedError",
    "if 0:",
    "if __name__ == .__main__.:",
]
EOF
    print_success "Created pyproject.toml"
fi

# Create Makefile
if [[ ! -f "Makefile" ]]; then
    cat > Makefile << 'EOF'
.PHONY: help install install-dev test lint format fix quality-check clean

help:  ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install:  ## Install production dependencies
	pip install -e .

install-dev:  ## Install development dependencies
	pip install -e ".[dev]"
	pre-commit install

test:  ## Run tests
	pytest

lint:  ## Run linting (without fixing)
	ruff check .

format-check:  ## Check code formatting
	ruff format --check .

format:  ## Format code
	ruff format .

fix:  ## Auto-fix linting issues
	ruff check --fix .
	ruff format .

quality-check:  ## Run all quality checks
	ruff check .
	ruff format --check .
	pytest

clean:  ## Clean up cache files
	find . -type d -name "__pycache__" -delete
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache
	rm -rf .ruff_cache
	rm -rf htmlcov
	rm -rf .coverage
	rm -rf dist
	rm -rf build
	rm -rf *.egg-info
EOF
    print_success "Created Makefile"
fi

# Create VSCode settings
mkdir -p .vscode
if [[ ! -f ".vscode/settings.json" ]]; then
    cat > .vscode/settings.json << 'EOF'
{
    "python.defaultInterpreterPath": "./.venv/bin/python",
    "python.terminal.activateEnvironment": true,
    "[python]": {
        "editor.defaultFormatter": "charliermarsh.ruff",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.fixAll.ruff": true,
            "source.organizeImports.ruff": true
        }
    },
    "ruff.lint.enable": true,
    "ruff.format.enable": true,
    "ruff.organizeImports": true,
    "files.exclude": {
        "**/__pycache__": true,
        "**/*.pyc": true,
        ".pytest_cache": true,
        ".ruff_cache": true,
        "htmlcov": true,
        ".coverage": true
    },
    "python.testing.pytestEnabled": true,
    "python.testing.unittestEnabled": false,
    "python.testing.pytestArgs": [
        "tests"
    ]
}
EOF
    print_success "Created VSCode settings"
fi

# Create pre-commit config
if [[ ! -f ".pre-commit-config.yaml" ]]; then
    cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.6
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]
      - id: ruff-format
EOF
    print_success "Created pre-commit configuration"
fi

# Create GitHub Actions workflow
if [[ "$SETUP_GITHUB_ACTIONS" == true ]]; then
    mkdir -p .github/workflows
    if [[ ! -f ".github/workflows/ci.yml" ]]; then
        cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.8", "3.9", "3.10", "3.11", "3.12"]

    steps:
    - uses: actions/checkout@v4

    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -e ".[dev]"

    - name: Lint with Ruff
      run: |
        ruff check .
        ruff format --check .

    - name: Test with pytest
      run: |
        pytest --cov=src --cov-report=xml

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        flags: unittests
        name: codecov-umbrella
EOF
        print_success "Created GitHub Actions workflow"
    fi
fi

# Create basic test file
mkdir -p tests
if [[ ! -f "tests/test_example.py" ]]; then
    cat > tests/test_example.py << 'EOF'
"""Example test module."""

import pytest


def test_example():
    """Example test function."""
    assert True


def test_addition():
    """Test basic addition."""
    assert 2 + 2 == 4


@pytest.mark.parametrize("input_value,expected", [
    (1, 2),
    (2, 3),
    (3, 4),
])
def test_increment(input_value, expected):
    """Test increment function with parametrize."""
    assert input_value + 1 == expected
EOF
    print_success "Created example test file"
fi

# Create __init__.py files
mkdir -p src/"$PROJECT_NAME"
mkdir -p tests
touch src/"$PROJECT_NAME"/__init__.py
touch tests/__init__.py

# Create project-specific Claude configuration
SCRIPT_DIR_PARENT="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"
CLAUDE_TEMPLATE="$SCRIPT_DIR_PARENT/claude/CLAUDE.md"

if [[ -f "$CLAUDE_TEMPLATE" ]]; then
    mkdir -p claude
    cp "$CLAUDE_TEMPLATE" claude/CLAUDE.md
    print_success "Added Claude Code configuration"
    
    # Update .gitignore to include claude/
    if [[ -f ".gitignore" ]] && ! grep -q "^claude/$" .gitignore; then
        echo "claude/" >> .gitignore
        print_success "Added claude/ to .gitignore"
    fi
else
    print_warning "Claude template not found, skipping Claude configuration"
fi

print_success "Configuration files created"