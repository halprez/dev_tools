#!/bin/bash
# Python Project Setup Tools - Shell Aliases
# Source this file in your shell profile for convenient shortcuts

# Main aliases
alias spp='python-project-setup'
alias ppv='python-project-verify'
alias pps='python-project-setup'  # Alternative naming

# Common project setup patterns
alias spp-minimal='python-project-setup --no-git'
alias spp-uv='python-project-setup --venv-tool uv'
alias spp-vscode='python-project-setup --vscode'
alias spp-full='python-project-setup --vscode --github-actions'
alias spp-existing='python-project-setup --existing'

# Python version shortcuts
alias spp38='python-project-setup --python 3.8'
alias spp39='python-project-setup --python 3.9'
alias spp310='python-project-setup --python 3.10'
alias spp311='python-project-setup --python 3.11'
alias spp312='python-project-setup --python 3.12'

# Development shortcuts (for use within projects)
alias mqc='make quality-check'
alias mfix='make fix'
alias mtest='make test'
alias mlint='make lint'
alias minstall='make install-dev'

# Quick project verification
alias check-project='python-project-verify'
alias verify-project='python-project-verify'

# Claude Code configuration shortcuts
alias claude-status='claude-config status'
alias claude-global='claude-config install-global'
alias claude-project='claude-config install-project'

# Function for even more convenience
spp-new() {
    if [ $# -eq 0 ]; then
        echo "Usage: spp-new <project-name> [python-version]"
        echo "Example: spp-new my-app 3.11"
        return 1
    fi
    
    local project_name="$1"
    local python_version="${2:-3.11}"
    
    echo "🚀 Creating Python project: $project_name (Python $python_version)"
    python-project-setup --python "$python_version" --venv-tool uv "$project_name"
}

# Function for quick existing project setup
spp-here() {
    echo "🔧 Setting up Python project in current directory: $(basename $(pwd))"
    python-project-setup --existing
}

# Function to create project and cd into it
spp-cd() {
    if [ $# -eq 0 ]; then
        echo "Usage: spp-cd <project-name> [python-version]"
        echo "Example: spp-cd my-app 3.11"
        return 1
    fi
    
    local project_name="$1"
    local python_version="${2:-3.11}"
    
    echo "🚀 Creating and entering Python project: $project_name"
    python-project-setup --python "$python_version" --venv-tool uv "$project_name" && cd "$project_name"
}

# Function to activate virtual environment in current project
activate() {
    if [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
        echo "✅ Activated virtual environment: $(basename $(pwd))"
    elif [ -f ".venv/Scripts/activate" ]; then
        source .venv/Scripts/activate
        echo "✅ Activated virtual environment: $(basename $(pwd))"
    else
        echo "❌ No virtual environment found in current directory"
        return 1
    fi
}

# Help function
spp-help() {
    cat << 'EOF'
🐍 Python Project Setup - Shell Shortcuts

MAIN COMMANDS:
    spp <name>              # Create new Python project (short for python-project-setup)
    ppv                     # Verify project setup (short for python-project-verify)
    
QUICK SETUP:
    spp-new <name> [ver]    # Create project with specified Python version
    spp-cd <name> [ver]     # Create project and cd into it
    spp-here               # Setup current directory as Python project
    spp-existing           # Setup existing project (alias)
    
SETUP VARIANTS:
    spp-minimal <name>     # No Git setup (bare minimum)
    spp-uv <name>          # Use uv for package management
    spp-vscode <name>      # Include VSCode configuration
    spp-full <name>        # VSCode + GitHub Actions
    
PYTHON VERSIONS:
    spp38 <name>           # Python 3.8
    spp39 <name>           # Python 3.9
    spp310 <name>          # Python 3.10
    spp311 <name>          # Python 3.11 (default)
    spp312 <name>          # Python 3.12
    
PROJECT COMMANDS:
    activate               # Activate project virtual environment
    mqc                    # make quality-check
    mtest                  # make test  
    mfix                   # make fix
    mlint                  # make lint
    minstall               # make install-dev
    
VERIFICATION:
    check-project          # Verify current project setup
    verify-project         # Same as above

CLAUDE CODE:
    claude-config          # Manage Claude Code configurations
    claude-status          # Check Claude configuration status
    claude-global          # Install global Claude configuration
    claude-project         # Install Claude config in current project

EXAMPLES:
    spp my-web-app                    # Basic setup
    spp-new api-service 3.12          # Python 3.12 project
    spp-cd ml-project 3.11            # Create and enter directory
    spp-uv fast-api                   # Use uv for speed
    spp-minimal simple-script         # Minimal setup
    cd existing-project && spp-here   # Setup existing directory
EOF
}

# Show a welcome message when sourced
if [ "${BASH_SOURCE[0]}" != "${0}" ] || [ -n "$ZSH_VERSION" ]; then
    echo "🐍 Python Project Setup shortcuts loaded!"
    echo "Type 'spp-help' for available commands"
fi