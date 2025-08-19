#!/bin/bash

# Claude Code Configuration Manager
# Manage CLAUDE.md files for global and project-specific configurations

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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CLAUDE_TEMPLATE="$PROJECT_ROOT/claude/CLAUDE.md"

# Claude Code directories
GLOBAL_CLAUDE_DIR="$HOME/.claude"
GLOBAL_CLAUDE_FILE="$GLOBAL_CLAUDE_DIR/CLAUDE.md"

show_help() {
    cat << EOF
Claude Code Configuration Manager

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    install-global         Install/update global Claude configuration
    backup-global         Backup current global configuration
    restore-global        Restore global configuration from backup
    install-project       Install Claude config in current project
    status                Show configuration status
    diff                  Compare configurations
    help                  Show this help

OPTIONS:
    --force               Overwrite existing files without confirmation
    --backup             Create backup before overwriting

EXAMPLES:
    $0 install-global                    # Install to ~/.claude/CLAUDE.md
    $0 install-global --backup           # Install with backup
    $0 install-project                   # Add CLAUDE.md to current project
    $0 status                            # Show current config status
    $0 diff                              # Compare global vs template

DESCRIPTION:
    This script manages Claude Code CLAUDE.md configuration files.
    The template includes best practices for Python development with
    SOLID principles, clean code guidelines, and project structure.
EOF
}

check_claude_template() {
    if [[ ! -f "$CLAUDE_TEMPLATE" ]]; then
        print_error "Claude template not found: $CLAUDE_TEMPLATE"
        print_error "Please run this script from the dev_tools directory"
        exit 1
    fi
}

show_status() {
    print_step "Claude Code Configuration Status"
    
    # Check global configuration
    if [[ -f "$GLOBAL_CLAUDE_FILE" ]]; then
        print_success "Global configuration exists: $GLOBAL_CLAUDE_FILE"
        
        # Show modification time
        local mod_time=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$GLOBAL_CLAUDE_FILE" 2>/dev/null || stat -c "%y" "$GLOBAL_CLAUDE_FILE" 2>/dev/null || echo "Unknown")
        print_color "  Last modified: $mod_time" "$CYAN"
        
        # Show size
        local size=$(wc -c < "$GLOBAL_CLAUDE_FILE" | tr -d ' ')
        print_color "  Size: $size bytes" "$CYAN"
    else
        print_warning "Global configuration not found: $GLOBAL_CLAUDE_FILE"
    fi
    
    # Check project configuration
    if [[ -f "claude/CLAUDE.md" ]]; then
        print_success "Project configuration exists: ./claude/CLAUDE.md"
    elif [[ -f "CLAUDE.md" ]]; then
        print_success "Project configuration exists: ./CLAUDE.md"
    else
        print_warning "No project configuration found"
    fi
    
    # Check template
    if [[ -f "$CLAUDE_TEMPLATE" ]]; then
        print_success "Template available: $CLAUDE_TEMPLATE"
    else
        print_error "Template missing: $CLAUDE_TEMPLATE"
    fi
}

backup_global() {
    if [[ ! -f "$GLOBAL_CLAUDE_FILE" ]]; then
        print_warning "No global configuration to backup"
        return 0
    fi
    
    local backup_file="$GLOBAL_CLAUDE_FILE.backup-$(date +%Y%m%d-%H%M%S)"
    
    print_step "Creating backup: $backup_file"
    cp "$GLOBAL_CLAUDE_FILE" "$backup_file"
    print_success "Backup created successfully"
    
    echo "$backup_file"  # Return backup path
}

restore_global() {
    local backup_files=("$GLOBAL_CLAUDE_DIR"/*.backup-*)
    
    if [[ ! -e "${backup_files[0]}" ]]; then
        print_error "No backup files found in $GLOBAL_CLAUDE_DIR"
        exit 1
    fi
    
    print_step "Available backups:"
    select backup_file in "${backup_files[@]}" "Cancel"; do
        case $backup_file in
            "Cancel")
                print_warning "Restore cancelled"
                exit 0
                ;;
            *)
                if [[ -n "$backup_file" ]]; then
                    print_step "Restoring from: $backup_file"
                    cp "$backup_file" "$GLOBAL_CLAUDE_FILE"
                    print_success "Global configuration restored"
                    break
                else
                    print_error "Invalid selection"
                fi
                ;;
        esac
    done
}

install_global() {
    local force=false
    local create_backup=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                force=true
                shift
                ;;
            --backup)
                create_backup=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    check_claude_template
    
    # Create Claude directory if it doesn't exist
    if [[ ! -d "$GLOBAL_CLAUDE_DIR" ]]; then
        print_step "Creating Claude directory: $GLOBAL_CLAUDE_DIR"
        mkdir -p "$GLOBAL_CLAUDE_DIR"
    fi
    
    # Check if file exists
    if [[ -f "$GLOBAL_CLAUDE_FILE" ]] && [[ "$force" != true ]]; then
        if [[ "$create_backup" == true ]]; then
            backup_global
        else
            print_warning "Global configuration already exists: $GLOBAL_CLAUDE_FILE"
            read -p "Overwrite existing file? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_warning "Installation cancelled"
                exit 0
            fi
        fi
    elif [[ -f "$GLOBAL_CLAUDE_FILE" ]] && [[ "$create_backup" == true ]]; then
        backup_global
    fi
    
    # Install configuration
    print_step "Installing global Claude configuration..."
    cp "$CLAUDE_TEMPLATE" "$GLOBAL_CLAUDE_FILE"
    
    print_success "Global Claude configuration installed!"
    print_color "Location: $GLOBAL_CLAUDE_FILE" "$CYAN"
    print_color "This configuration will be used by Claude Code globally" "$BLUE"
}

install_project() {
    local force=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                force=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    check_claude_template
    
    # Determine project structure
    local project_claude_file
    if [[ -d "claude" ]]; then
        project_claude_file="claude/CLAUDE.md"
        print_step "Using existing claude/ directory"
    elif [[ -f "claude/CLAUDE.md" ]] || [[ ! -f "CLAUDE.md" ]]; then
        # Create claude directory for consistency
        mkdir -p claude
        project_claude_file="claude/CLAUDE.md"
        print_step "Created claude/ directory"
    else
        project_claude_file="CLAUDE.md"
        print_step "Using root directory for CLAUDE.md"
    fi
    
    # Check if file exists
    if [[ -f "$project_claude_file" ]] && [[ "$force" != true ]]; then
        print_warning "Project configuration already exists: $project_claude_file"
        read -p "Overwrite existing file? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_warning "Installation cancelled"
            exit 0
        fi
    fi
    
    # Install configuration
    print_step "Installing project Claude configuration..."
    cp "$CLAUDE_TEMPLATE" "$project_claude_file"
    
    print_success "Project Claude configuration installed!"
    print_color "Location: $project_claude_file" "$CYAN"
    print_color "This configuration will be used for this project only" "$BLUE"
    
    # Update .gitignore if it exists
    if [[ -f ".gitignore" ]] && ! grep -q "^claude/$" .gitignore 2>/dev/null; then
        if [[ "$project_claude_file" == "claude/CLAUDE.md" ]]; then
            echo "" >> .gitignore
            echo "# Claude Code configuration" >> .gitignore
            echo "claude/" >> .gitignore
            print_success "Added claude/ to .gitignore"
        fi
    fi
}

compare_configs() {
    check_claude_template
    
    print_step "Comparing configurations..."
    
    if [[ ! -f "$GLOBAL_CLAUDE_FILE" ]]; then
        print_warning "No global configuration to compare"
        return 1
    fi
    
    print_color "Comparing global config with template:" "$BLUE"
    if command -v diff &> /dev/null; then
        diff -u "$GLOBAL_CLAUDE_FILE" "$CLAUDE_TEMPLATE" || true
    else
        print_warning "diff command not available"
        print_step "Global config size: $(wc -c < "$GLOBAL_CLAUDE_FILE" | tr -d ' ') bytes"
        print_step "Template size: $(wc -c < "$CLAUDE_TEMPLATE" | tr -d ' ') bytes"
    fi
}

main() {
    local command="${1:-help}"
    shift || true
    
    print_color "
🤖 CLAUDE CODE CONFIGURATION MANAGER
" "$CYAN"
    
    case "$command" in
        "install-global"|"global")
            install_global "$@"
            ;;
        "backup-global"|"backup")
            backup_global
            ;;
        "restore-global"|"restore")
            restore_global
            ;;
        "install-project"|"project")
            install_project "$@"
            ;;
        "status"|"check")
            show_status
            ;;
        "diff"|"compare")
            compare_configs
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Only run main if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi