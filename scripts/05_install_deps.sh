#!/bin/bash

# Install dependencies script

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

VENV_TOOL="$1"
CREATE_VENV="$2"

print_step "Installing Python dependencies..."

# Activate virtual environment if created
if [[ "$CREATE_VENV" == true ]]; then
    if [[ -f ".venv/bin/activate" ]]; then
        source .venv/bin/activate
        print_step "Activated virtual environment"
    elif [[ -f ".venv/Scripts/activate" ]]; then
        source .venv/Scripts/activate
        print_step "Activated virtual environment"
    else
        print_warning "Virtual environment not found, installing globally"
    fi
fi

# Get selected venv tool
if [[ -f "/tmp/selected_venv_tool" ]]; then
    SELECTED_TOOL=$(cat /tmp/selected_venv_tool)
else
    SELECTED_TOOL="$VENV_TOOL"
fi

# Install dependencies based on tool
case "$SELECTED_TOOL" in
    "uv")
        print_step "Installing dependencies with uv..."
        if ! uv pip install -e ".[dev]"; then
            print_error "Failed to install dependencies with uv"
            exit 1
        fi
        ;;
    "venv"|*)
        print_step "Installing dependencies with pip..."
        if ! python -m pip install --upgrade pip; then
            print_error "Failed to upgrade pip"
            exit 1
        fi
        
        if ! python -m pip install -e ".[dev]"; then
            print_error "Failed to install dependencies with pip"
            exit 1
        fi
        ;;
esac

print_success "Dependencies installed successfully"

# Show installed packages
print_step "Installed packages:"
if command -v uv &> /dev/null && [[ "$SELECTED_TOOL" == "uv" ]]; then
    uv pip list | head -20
else
    python -m pip list | head -20
fi

print_success "Python dependencies setup complete"