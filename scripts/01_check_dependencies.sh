#!/bin/bash

# Check dependencies script

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
SETUP_GIT="$3"
INSTALL_VSCODE_CONFIG="$4"

print_step "Checking dependencies..."

missing_deps=()

# Python
if ! command -v python3 &> /dev/null; then
    missing_deps+=("python3")
fi

# pip
if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
    missing_deps+=("pip")
fi

# Git (optional)
if [[ "$SETUP_GIT" == true ]] && ! command -v git &> /dev/null; then
    print_warning "Git not found. Disabling Git configuration."
fi

# VSCode (optional)
if [[ "$INSTALL_VSCODE_CONFIG" == true ]] && ! command -v code &> /dev/null; then
    print_warning "VSCode CLI not found. VSCode configuration will still be created."
fi

# Check virtual environment tools
if [[ "$CREATE_VENV" == true ]]; then
    uv_available=false
    venv_available=false
    
    if command -v uv &> /dev/null; then
        uv_available=true
        print_success "uv found: $(uv --version)"
    fi
    
    if python3 -m venv --help &> /dev/null; then
        venv_available=true
        print_success "Standard venv available"
    fi
    
    case "$VENV_TOOL" in
        "auto")
            if [[ "$uv_available" == true ]]; then
                echo "uv" > /tmp/selected_venv_tool
                print_success "Auto-detected: using uv (recommended)"
            elif [[ "$venv_available" == true ]]; then
                echo "venv" > /tmp/selected_venv_tool
                print_success "Auto-detected: using standard venv"
            else
                print_error "No virtual environment tool found"
                print_error "Install uv: curl -LsSf https://astral.sh/uv/install.sh | sh"
                exit 1
            fi
            ;;
        "uv")
            if [[ "$uv_available" != true ]]; then
                print_error "uv not found but specifically requested"
                print_error "Install uv: curl -LsSf https://astral.sh/uv/install.sh | sh"
                exit 1
            fi
            echo "uv" > /tmp/selected_venv_tool
            ;;
        "venv")
            if [[ "$venv_available" != true ]]; then
                print_error "venv not available (requires Python 3.3+)"
                exit 1
            fi
            echo "venv" > /tmp/selected_venv_tool
            ;;
    esac
fi

if [[ ${#missing_deps[@]} -gt 0 ]]; then
    print_error "Missing dependencies: ${missing_deps[*]}"
    exit 1
fi

print_success "All dependencies available"