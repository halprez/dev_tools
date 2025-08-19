#!/bin/bash

# Create virtual environment script

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_color() { printf "${2}${1}${NC}\n"; }
print_step() { print_color "🔧 $1" "$BLUE"; }
print_success() { print_color "✅ $1" "$GREEN"; }
print_warning() { print_color "⚠️  $1" "$YELLOW"; }
print_error() { print_color "❌ $1" "$RED"; }

# Get selected venv tool from previous step
if [[ -f "/tmp/selected_venv_tool" ]]; then
    VENV_TOOL=$(cat /tmp/selected_venv_tool)
else
    VENV_TOOL="$1"
fi

PYTHON_VERSION="$2"

print_step "Creating virtual environment with $VENV_TOOL..."

venv_path=".venv"

# Check if already exists
if [[ -d "$venv_path" ]]; then
    print_warning "Virtual environment already exists at $venv_path"
    read -p "Recreate virtual environment? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Removing existing virtual environment..."
        rm -rf "$venv_path"
    else
        print_success "Using existing virtual environment"
        exit 0
    fi
fi

# Create virtual environment
case "$VENV_TOOL" in
    "uv")
        print_step "Creating virtual environment with uv..."
        if ! uv venv "$venv_path" --python "$PYTHON_VERSION"; then
            print_error "Error creating virtual environment with uv"
            exit 1
        fi
        ;;
    "venv")
        print_step "Creating virtual environment with standard venv..."
        python_cmd="python3"
        if command -v "python$PYTHON_VERSION" &> /dev/null; then
            python_cmd="python$PYTHON_VERSION"
        fi
        
        if ! "$python_cmd" -m venv "$venv_path"; then
            print_error "Error creating virtual environment with venv"
            exit 1
        fi
        
        # Activate and update pip
        if [[ -f "$venv_path/bin/activate" ]]; then
            source "$venv_path/bin/activate"
        elif [[ -f "$venv_path/Scripts/activate" ]]; then
            source "$venv_path/Scripts/activate"
        fi
        
        print_step "Updating pip..."
        python -m pip install --upgrade pip
        ;;
esac

print_success "Virtual environment created at $venv_path"

# Show activation instructions
print_color "\n📝 TO ACTIVATE VIRTUAL ENVIRONMENT:" "$YELLOW"
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    print_color "Windows: $venv_path\\Scripts\\activate" "$CYAN"
else
    print_color "Linux/Mac: source $venv_path/bin/activate" "$CYAN"
fi
print_color "To deactivate: deactivate" "$CYAN"