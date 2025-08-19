#!/bin/bash

# Python Project Setup Tools - Installer
# Installs setup commands system-wide for easy access

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

# Get script directory (where this install.sh is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# Installation directories
LOCAL_BIN="$HOME/.local/bin"
SYSTEM_BIN="/usr/local/bin"

# Configuration
INSTALL_SHELL_INTEGRATION=false
INSTALL_CLAUDE_CONFIG=false
INSTALL_VSCODE_EXTENSIONS=false

show_help() {
    cat << EOF
Python Project Setup Tools - Installer

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help          Show this help
    --system           Install system-wide (requires sudo)
    --local            Install to ~/.local/bin (default)
    --uninstall        Uninstall the tools
    --check            Check installation status
    --shell-integration Install shell aliases and completion
    --no-shell         Skip shell integration (default)
    --claude-config    Install/update global Claude Code configuration
    --no-claude        Skip Claude configuration (default)
    --vscode-extensions Install recommended VSCode extensions
    --no-vscode        Skip VSCode extensions (default)

EXAMPLES:
    $0                 # Install to ~/.local/bin
    $0 --system        # Install to /usr/local/bin
    $0 --shell-integration    # Install with shell shortcuts (spp, ppv, etc.)
    $0 --claude-config        # Install with global Claude Code config
    $0 --shell-integration --claude-config --vscode-extensions  # Full installation
    $0 --uninstall     # Remove installation
    $0 --check         # Check what's installed

COMMANDS INSTALLED:
    python-project-setup    # Main setup command
    python-project-verify   # Verify existing project setup

SHELL SHORTCUTS (with --shell-integration):
    spp, spp-new, spp-cd    # Quick project creation
    ppv, check-project      # Project verification  
    mqc, mtest, mfix        # Development commands
    claude-config           # Manage Claude Code configurations

CLAUDE CODE INTEGRATION (with --claude-config):
    Global CLAUDE.md        # Best practices for Python development
    Project templates       # Automatic Claude config in new projects
EOF
}

check_installation() {
    print_step "Checking installation status..."
    
    # Check for commands in PATH
    commands=("python-project-setup" "python-project-verify")
    found_count=0
    
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            location=$(which "$cmd")
            print_success "✓ $cmd found at: $location"
            ((found_count++))
        else
            print_warning "✗ $cmd not found in PATH"
        fi
    done
    
    if [[ $found_count -eq ${#commands[@]} ]]; then
        print_success "All commands are properly installed!"
    else
        print_warning "Some commands are missing or not in PATH"
    fi
    
    # Show PATH info
    print_step "Current PATH includes:"
    echo "$PATH" | tr ':' '\n' | grep -E "(local/bin|usr/local/bin)" | head -5
}

install_shell_integration() {
    print_step "Installing shell integration (aliases and completion)..."
    
    local shell_files=()
    local integration_installed=false
    
    # Detect shell and shell config files
    if [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == */bash ]]; then
        shell_files+=("$HOME/.bashrc")
        [[ -f "$HOME/.bash_profile" ]] && shell_files+=("$HOME/.bash_profile")
    fi
    
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == */zsh ]]; then
        shell_files+=("$HOME/.zshrc")
    fi
    
    # Add generic shell files if no specific shell detected
    if [[ ${#shell_files[@]} -eq 0 ]]; then
        [[ -f "$HOME/.bashrc" ]] && shell_files+=("$HOME/.bashrc")
        [[ -f "$HOME/.zshrc" ]] && shell_files+=("$HOME/.zshrc")
        [[ -f "$HOME/.profile" ]] && shell_files+=("$HOME/.profile")
    fi
    
    if [[ ${#shell_files[@]} -eq 0 ]]; then
        print_error "No shell configuration files found"
        print_error "Please manually source: $SCRIPT_DIR/shell/aliases.sh"
        return 1
    fi
    
    # Add integration to shell files
    local integration_block="
# Python Project Setup Tools - Shell Integration
if [ -f \"$SCRIPT_DIR/shell/aliases.sh\" ]; then
    source \"$SCRIPT_DIR/shell/aliases.sh\"
fi

if [ -n \"\$BASH_VERSION\" ] && [ -f \"$SCRIPT_DIR/shell/bash_completion.sh\" ]; then
    source \"$SCRIPT_DIR/shell/bash_completion.sh\"
fi

if [ -n \"\$ZSH_VERSION\" ] && [ -f \"$SCRIPT_DIR/shell/zsh_completion.zsh\" ]; then
    source \"$SCRIPT_DIR/shell/zsh_completion.zsh\"
fi"
    
    for shell_file in "${shell_files[@]}"; do
        if [[ -f "$shell_file" ]]; then
            # Check if already installed
            if grep -q "Python Project Setup Tools - Shell Integration" "$shell_file" 2>/dev/null; then
                print_warning "Shell integration already exists in $shell_file"
                continue
            fi
            
            # Add integration
            echo "$integration_block" >> "$shell_file"
            print_success "Added shell integration to $shell_file"
            integration_installed=true
        fi
    done
    
    if [[ "$integration_installed" == true ]]; then
        print_success "Shell integration installed!"
        print_warning "Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
        print_step "Available shortcuts: spp, ppv, spp-new, spp-cd, mqc, mtest, etc."
        print_step "Type 'spp-help' after restart for full list"
    else
        print_error "Failed to install shell integration"
        return 1
    fi
}

uninstall_shell_integration() {
    print_step "Removing shell integration..."
    
    local shell_files=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile" 
        "$HOME/.zshrc"
        "$HOME/.profile"
    )
    
    local removed_count=0
    
    for shell_file in "${shell_files[@]}"; do
        if [[ -f "$shell_file" ]] && grep -q "Python Project Setup Tools - Shell Integration" "$shell_file" 2>/dev/null; then
            # Create backup
            cp "$shell_file" "${shell_file}.backup-$(date +%Y%m%d-%H%M%S)"
            
            # Remove integration block
            sed -i.tmp '/# Python Project Setup Tools - Shell Integration/,/fi$/d' "$shell_file"
            rm -f "${shell_file}.tmp"
            
            print_success "Removed shell integration from $shell_file"
            ((removed_count++))
        fi
    done
    
    if [[ $removed_count -gt 0 ]]; then
        print_success "Removed shell integration from $removed_count file(s)"
        print_warning "Restart your shell for changes to take effect"
    else
        print_warning "No shell integration found to remove"
    fi
}

uninstall_tools() {
    print_step "Uninstalling Python project setup tools..."
    
    # Remove shell integration first
    uninstall_shell_integration
    
    # Commands to remove
    commands=("python-project-setup" "python-project-verify")
    
    # Check both local and system directories
    install_dirs=("$LOCAL_BIN" "$SYSTEM_BIN")
    
    removed_count=0
    for install_dir in "${install_dirs[@]}"; do
        for cmd in "${commands[@]}"; do
            cmd_path="$install_dir/$cmd"
            if [[ -L "$cmd_path" ]] || [[ -f "$cmd_path" ]]; then
                if rm -f "$cmd_path"; then
                    print_success "Removed: $cmd_path"
                    ((removed_count++))
                else
                    print_error "Failed to remove: $cmd_path"
                fi
            fi
        done
    done
    
    if [[ $removed_count -gt 0 ]]; then
        print_success "Uninstalled $removed_count command(s)"
    else
        print_warning "No installed commands found to remove"
    fi
}

install_tools() {
    local install_dir="$1"
    local use_sudo="$2"
    
    print_step "Installing Python project setup tools to $install_dir..."
    
    # Check if install directory exists
    if [[ ! -d "$install_dir" ]]; then
        print_step "Creating directory: $install_dir"
        if [[ "$use_sudo" == true ]]; then
            sudo mkdir -p "$install_dir"
        else
            mkdir -p "$install_dir"
        fi
    fi
    
    # Verify scripts directory exists
    if [[ ! -d "$SCRIPTS_DIR" ]]; then
        print_error "Scripts directory not found: $SCRIPTS_DIR"
        print_error "Please run this installer from the dev_tools directory"
        exit 1
    fi
    
    # Create wrapper scripts
    install_count=0
    
    # Main setup command
    setup_script="$install_dir/python-project-setup"
    cat > "$setup_script" << EOF
#!/bin/bash
# Python Project Setup Tool
# Wrapper script for python project setup
exec "$SCRIPTS_DIR/setup_python_project.sh" "\$@"
EOF
    
    if [[ "$use_sudo" == true ]]; then
        sudo chmod +x "$setup_script"
    else
        chmod +x "$setup_script"
    fi
    print_success "Created: python-project-setup"
    ((install_count++))
    
    # Verification command
    verify_script="$install_dir/python-project-verify"
    cat > "$verify_script" << EOF
#!/bin/bash
# Python Project Verification Tool
# Wrapper script for project verification
exec "$SCRIPTS_DIR/08_verify_setup.sh" "\$@"
EOF
    
    if [[ "$use_sudo" == true ]]; then
        sudo chmod +x "$verify_script"
    else
        chmod +x "$verify_script"
    fi
    print_success "Created: python-project-verify"
    ((install_count++))
    
    # Create Claude config management command
    claude_config_script="$install_dir/claude-config"
    cat > "$claude_config_script" << EOF
#!/bin/bash
# Claude Code Configuration Manager
# Wrapper script for Claude configuration management
exec "$SCRIPTS_DIR/manage_claude_config.sh" "\$@"
EOF
    
    if [[ "$use_sudo" == true ]]; then
        sudo chmod +x "$claude_config_script"
    else
        chmod +x "$claude_config_script"
    fi
    print_success "Created: claude-config"
    ((install_count++))
    
    print_success "Installed $install_count command(s) to $install_dir"
    
    # Check if install_dir is in PATH
    if ! echo "$PATH" | grep -q "$install_dir"; then
        print_warning "$install_dir is not in your PATH"
        print_warning "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        print_color "export PATH=\"$install_dir:\$PATH\"" "$CYAN"
        print_warning "Then restart your shell or run: source ~/.bashrc"
    else
        print_success "$install_dir is already in your PATH"
    fi
}

install_claude_config() {
    print_step "Installing Claude Code global configuration..."
    
    # Use the Claude config management script
    if [[ -x "$SCRIPTS_DIR/manage_claude_config.sh" ]]; then
        "$SCRIPTS_DIR/manage_claude_config.sh" install-global --backup
        print_success "Claude Code configuration installed!"
        print_step "Use 'claude-config status' to check configuration"
        print_step "Use 'claude-config help' for more options"
    else
        print_error "Claude config management script not found"
        print_error "Expected: $SCRIPTS_DIR/manage_claude_config.sh"
        return 1
    fi
}

install_vscode_extensions() {
    print_step "Installing recommended VSCode extensions..."
    
    # Check if VSCode CLI is available
    if ! command -v code &> /dev/null; then
        print_warning "VSCode CLI not found. Please install VSCode and add 'code' to your PATH."
        print_warning "Then install these extensions manually:"
        print_color "  - Python (ms-python.python)" "$YELLOW"
        print_color "  - Ruff (charliermarsh.ruff)" "$YELLOW"
        print_color "  - GitLens (eamodio.gitlens)" "$YELLOW"
        print_color "  - Python Docstring Generator (njpwerner.autodocstring)" "$YELLOW"
        return 1
    fi
    
    # List of recommended extensions
    local extensions=(
        "ms-python.python"              # Python support
        "charliermarsh.ruff"            # Ruff linting and formatting
        "eamodio.gitlens"              # Git integration
        "njpwerner.autodocstring"       # Python docstring generator
        "ms-python.pylint"             # Additional Python linting
        "ms-toolsai.jupyter"           # Jupyter notebook support
        "donjayamanne.python-environment-manager"  # Python environment manager
        "ms-vscode.vscode-json"        # JSON support
        "redhat.vscode-yaml"           # YAML support
        "ms-vscode.makefile-tools"     # Makefile support
    )
    
    # Install extensions
    local installed_count=0
    local failed_count=0
    local already_installed=0
    
    for extension in "${extensions[@]}"; do
        if code --list-extensions | grep -q "^$extension$"; then
            print_success "✓ $extension already installed"
            ((already_installed++))
        else
            print_step "Installing $extension..."
            if code --install-extension "$extension" --force; then
                print_success "✓ $extension installed"
                ((installed_count++))
            else
                print_warning "✗ Failed to install $extension"
                ((failed_count++))
            fi
        fi
    done
    
    # Show summary
    print_step "VSCode Extensions Summary:"
    if [[ $already_installed -gt 0 ]]; then
        print_success "✅ Already installed: $already_installed extensions"
    fi
    if [[ $installed_count -gt 0 ]]; then
        print_success "✅ Newly installed: $installed_count extensions"
    fi
    if [[ $failed_count -gt 0 ]]; then
        print_warning "⚠️  Failed to install: $failed_count extensions"
    fi
    
    print_success "VSCode extensions setup complete!"
    print_step "Extensions are installed globally and will work in all your projects"
}

main() {
    print_color "
🚀 PYTHON PROJECT SETUP TOOLS - INSTALLER
" "$CYAN"
    
    # Default values
    install_location="local"
    action="install"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            --system)
                install_location="system"
                shift
                ;;
            --local)
                install_location="local"
                shift
                ;;
            --shell-integration)
                INSTALL_SHELL_INTEGRATION=true
                shift
                ;;
            --no-shell)
                INSTALL_SHELL_INTEGRATION=false
                shift
                ;;
            --claude-config)
                INSTALL_CLAUDE_CONFIG=true
                shift
                ;;
            --no-claude)
                INSTALL_CLAUDE_CONFIG=false
                shift
                ;;
            --vscode-extensions)
                INSTALL_VSCODE_EXTENSIONS=true
                shift
                ;;
            --no-vscode)
                INSTALL_VSCODE_EXTENSIONS=false
                shift
                ;;
            --uninstall)
                action="uninstall"
                shift
                ;;
            --check)
                action="check"
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    case "$action" in
        "check")
            check_installation
            exit 0
            ;;
        "uninstall")
            uninstall_tools
            exit 0
            ;;
        "install")
            # Continue with installation
            ;;
    esac
    
    # Determine installation directory and sudo requirement
    if [[ "$install_location" == "system" ]]; then
        install_dir="$SYSTEM_BIN"
        use_sudo=true
        print_step "Installing system-wide (requires sudo privileges)"
        
        # Check if we can use sudo
        if ! sudo -n true 2>/dev/null; then
            print_step "This installation requires sudo privileges"
            sudo -v  # Prompt for password
        fi
    else
        install_dir="$LOCAL_BIN"
        use_sudo=false
        print_step "Installing to user directory (no sudo required)"
    fi
    
    # Perform installation
    install_tools "$install_dir" "$use_sudo"
    
    # Install shell integration if requested
    if [[ "$INSTALL_SHELL_INTEGRATION" == true ]]; then
        install_shell_integration
    fi
    
    # Install Claude configuration if requested
    if [[ "$INSTALL_CLAUDE_CONFIG" == true ]]; then
        install_claude_config
    fi
    
    # Install VSCode extensions if requested
    if [[ "$INSTALL_VSCODE_EXTENSIONS" == true ]]; then
        install_vscode_extensions
    fi
    
    print_color "
═══════════════════════════════════════════════════════════════" "$CYAN"
    print_color "INSTALLATION COMPLETE! 🎉" "$MAGENTA"
    print_color "═══════════════════════════════════════════════════════════════" "$CYAN"
    
    print_color "
📚 AVAILABLE COMMANDS:" "$GREEN"
    print_color "  python-project-setup my-project    # Create new Python project" "$YELLOW"
    print_color "  python-project-setup --help        # Show all options" "$YELLOW"
    print_color "  python-project-verify               # Verify existing project" "$YELLOW"
    
    if [[ "$INSTALL_SHELL_INTEGRATION" == true ]]; then
        print_color "
🚀 SHELL SHORTCUTS:" "$GREEN"
        print_color "  spp my-project                      # Quick project setup" "$YELLOW"
        print_color "  spp-new my-app 3.12                 # Create with Python version" "$YELLOW"
        print_color "  spp-cd my-project                   # Create and enter directory" "$YELLOW"
        print_color "  ppv                                 # Quick project verify" "$YELLOW"
        print_color "  spp-help                            # Show all shortcuts" "$YELLOW"
    fi
    
    print_color "
🔧 EXAMPLES:" "$GREEN"
    print_color "  python-project-setup my-web-app" "$BLUE"
    print_color "  python-project-setup --venv-tool uv --python 3.12 modern-project" "$BLUE"
    print_color "  cd existing-project && python-project-setup --existing" "$BLUE"
    
    if [[ "$install_location" == "local" ]] && ! echo "$PATH" | grep -q "$LOCAL_BIN"; then
        print_color "
⚠️  IMPORTANT: Add ~/.local/bin to your PATH" "$YELLOW"
        print_color "Add this line to your shell profile (~/.bashrc, ~/.zshrc, etc.):" "$BLUE"
        print_color "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$CYAN"
        print_color "Then restart your shell or run: source ~/.bashrc" "$BLUE"
    fi
    
    print_color "
🎯 NEXT STEPS:" "$GREEN"
    print_color "1. Create your first project: python-project-setup my-project" "$BLUE"
    print_color "2. Start coding in src/my-project/" "$BLUE"
    print_color "3. Run quality checks: make quality-check" "$BLUE"
    
    print_success "Happy coding! 🐍✨"
}

# Only run main if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi