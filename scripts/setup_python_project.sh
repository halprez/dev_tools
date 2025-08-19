#!/bin/bash

# =============================================================================
# PYTHON PROJECT SETUP SCRIPT WITH RUFF + VSCODE
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_color() { printf "${2}${1}${NC}\n"; }
print_step() { print_color "🔧 $1" "$BLUE"; }
print_success() { print_color "✅ $1" "$GREEN"; }
print_warning() { print_color "⚠️  $1" "$YELLOW"; }
print_error() { print_color "❌ $1" "$RED"; }

# Variables
PROJECT_NAME=""
PYTHON_VERSION="3.11"
INSTALL_VSCODE_CONFIG=false
SETUP_GIT=true
SETUP_GITHUB_ACTIONS=false
CREATE_VENV=true
VENV_TOOL="auto"

show_help() {
    cat << EOF
Usage: $0 [OPTIONS] [PROJECT_NAME]

OPTIONS:
    -h, --help              Show help
    -n, --name NAME         Project name
    -p, --python VERSION    Python version (default: 3.11)
    --vscode               Create VSCode configuration files (default: off)
    --no-git              Don't configure Git
    --github-actions      Configure GitHub Actions workflow
    --no-venv             Don't create virtual environment
    --venv-tool TOOL      Virtual environment tool: venv, uv, auto
    --existing            Configure current directory

EXAMPLES:
    $0 my-python-project
    $0 --venv-tool uv my-project
    $0 --existing
EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) show_help; exit 0 ;;
            -n|--name) PROJECT_NAME="$2"; shift 2 ;;
            -p|--python) PYTHON_VERSION="$2"; shift 2 ;;
            --vscode) INSTALL_VSCODE_CONFIG=true; shift ;;
            --no-git) SETUP_GIT=false; shift ;;
            --github-actions) SETUP_GITHUB_ACTIONS=true; shift ;;
            --no-venv) CREATE_VENV=false; shift ;;
            --venv-tool) VENV_TOOL="$2"; shift 2 ;;
            --existing) PROJECT_NAME=$(basename "$PWD"); shift ;;
            -*) print_error "Unknown option: $1"; exit 1 ;;
            *) PROJECT_NAME="$1"; shift ;;
        esac
    done

    if [[ -z "$PROJECT_NAME" ]]; then
        print_error "Project name is required"
        show_help
        exit 1
    fi
}

main() {
    print_color "🚀 PYTHON PROJECT SETUP" "$CYAN"
    
    parse_arguments "$@"
    
    print_step "Project: $PROJECT_NAME"
    print_step "Python: $PYTHON_VERSION"
    print_step "Virtual env: $VENV_TOOL"
    
    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Run setup steps
    "$SCRIPT_DIR/01_check_dependencies.sh" "$VENV_TOOL" "$CREATE_VENV" "$SETUP_GIT" "$INSTALL_VSCODE_CONFIG"
    "$SCRIPT_DIR/02_create_structure.sh" "$PROJECT_NAME" "$@"
    
    # Change to project directory if not existing project
    existing_project=false
    for arg in "$@"; do
        if [[ "$arg" == "--existing" ]]; then
            existing_project=true
            break
        fi
    done
    
    if [[ "$existing_project" != true ]]; then
        cd "$PROJECT_NAME"
    fi
    
    if [[ "$CREATE_VENV" == true ]]; then
        "$SCRIPT_DIR/03_create_venv.sh" "$VENV_TOOL" "$PYTHON_VERSION"
    fi
    
    "$SCRIPT_DIR/04_create_configs.sh" "$PROJECT_NAME" "$SETUP_GITHUB_ACTIONS"
    "$SCRIPT_DIR/05_install_deps.sh" "$VENV_TOOL" "$CREATE_VENV"
    
    if [[ "$SETUP_GIT" == true ]]; then
        "$SCRIPT_DIR/06_setup_git.sh"
    fi
    
    if [[ "$INSTALL_VSCODE_CONFIG" == true ]]; then
        "$SCRIPT_DIR/07_install_vscode.sh"
    fi
    
    "$SCRIPT_DIR/08_verify_setup.sh"
    "$SCRIPT_DIR/09_show_summary.sh" "$PROJECT_NAME" "$PYTHON_VERSION" "$VENV_TOOL" "$CREATE_VENV"
    
    print_success "Setup completed! 🎉"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi