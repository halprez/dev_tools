#!/bin/bash

# Install VSCode extensions script

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

create_vscode_configs() {
    print_step "Creating VSCode configuration files..."
    
    # Create VSCode launch configuration for debugging
    mkdir -p .vscode
    if [[ ! -f ".vscode/launch.json" ]]; then
        cat > .vscode/launch.json << 'EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Current File",
            "type": "python",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "justMyCode": true
        },
        {
            "name": "Python: Debug Tests",
            "type": "python",
            "request": "launch",
            "module": "pytest",
            "args": ["${workspaceFolder}/tests"],
            "console": "integratedTerminal",
            "justMyCode": false
        }
    ]
}
EOF
        print_success "Created VSCode launch configuration"
    fi

    # Create tasks configuration
    if [[ ! -f ".vscode/tasks.json" ]]; then
        cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Run Tests",
            "type": "shell",
            "command": "make",
            "args": ["test"],
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Quality Check",
            "type": "shell",
            "command": "make",
            "args": ["quality-check"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Fix Code",
            "type": "shell",
            "command": "make",
            "args": ["fix"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        }
    ]
}
EOF
        print_success "Created VSCode tasks configuration"
    fi
}

print_step "Creating VSCode project configuration..."

# Create VSCode configuration files (extensions handled by installer)
create_vscode_configs

print_success "VSCode project configuration complete"

# Show post-installation instructions
print_color "\n📝 VSCODE PROJECT SETUP COMPLETE:" "$YELLOW"
print_color "1. Open this project in VSCode: code ." "$BLUE"
print_color "2. Select Python interpreter: Ctrl+Shift+P → 'Python: Select Interpreter'" "$BLUE"
print_color "3. Choose the virtual environment: ./.venv/bin/python" "$BLUE"
print_color "4. Run tests: Ctrl+Shift+P → 'Tasks: Run Task' → 'Run Tests'" "$BLUE"

# Note about extensions
if ! command -v code &> /dev/null; then
    print_warning "\nVSCode CLI not found. For full setup, install VSCode then run:"
    print_color "./install.sh --vscode-extensions" "$CYAN"
else
    # Check if extensions are installed
    local missing_extensions=0
    local essential_extensions=("ms-python.python" "charliermarsh.ruff")
    
    for ext in "${essential_extensions[@]}"; do
        if ! code --list-extensions | grep -q "^$ext$"; then
            ((missing_extensions++))
        fi
    done
    
    if [[ $missing_extensions -gt 0 ]]; then
        print_warning "\nSome recommended extensions may be missing. To install them:"
        print_color "./install.sh --vscode-extensions" "$CYAN"
    else
        print_success "✅ Essential VSCode extensions are installed"
    fi
fi