#!/bin/bash
# Python Project Setup Tools - Bash Completion

_python_project_setup_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Available options
    opts="--help -h --name -n --python -p --no-vscode --no-git --no-github-actions --no-venv --venv-tool --existing"

    case $prev in
        --python|-p)
            # Python version completions
            COMPREPLY=( $(compgen -W "3.8 3.9 3.10 3.11 3.12" -- "$cur") )
            return 0
            ;;
        --venv-tool)
            # Virtual environment tool completions
            COMPREPLY=( $(compgen -W "auto uv venv" -- "$cur") )
            return 0
            ;;
        --name|-n)
            # Don't complete anything for name, let user type
            return 0
            ;;
    esac

    if [[ $cur == -* ]]; then
        # Complete options
        COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    else
        # Complete directory names for project names
        COMPREPLY=( $(compgen -d -- "$cur") )
    fi
}

_python_project_verify_completion() {
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    
    # python-project-verify doesn't take arguments
    if [[ $cur == -* ]]; then
        COMPREPLY=( $(compgen -W "--help -h" -- "$cur") )
    fi
}

# Completion for short aliases
_spp_completion() {
    _python_project_setup_completion
}

# Register completions
complete -F _python_project_setup_completion python-project-setup
complete -F _python_project_verify_completion python-project-verify
complete -F _spp_completion spp
complete -F _spp_completion pps
complete -F _spp_completion spp-quick
complete -F _spp_completion spp-minimal
complete -F _spp_completion spp-uv
complete -F _spp_completion spp38
complete -F _spp_completion spp39
complete -F _spp_completion spp310
complete -F _spp_completion spp311
complete -F _spp_completion spp312

# Directory completion for spp-new and spp-cd functions
_spp_new_completion() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case $COMP_CWORD in
        1)
            # First argument: project name (no completion, let user type)
            return 0
            ;;
        2)
            # Second argument: Python version
            COMPREPLY=( $(compgen -W "3.8 3.9 3.10 3.11 3.12" -- "$cur") )
            return 0
            ;;
    esac
}

complete -F _spp_new_completion spp-new
complete -F _spp_new_completion spp-cd

# Show completion help
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo "🔧 Bash completion for Python Project Setup loaded!"
fi