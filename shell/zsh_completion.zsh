#!/usr/bin/env zsh
# Python Project Setup Tools - Zsh Completion

_python_project_setup() {
    local context state state_descr line
    typeset -A opt_args

    _arguments -C \
        '(--help -h)'{--help,-h}'[Show help message]' \
        '(--name -n)'{--name,-n}'[Project name]:name:' \
        '(--python -p)'{--python,-p}'[Python version]:version:(3.8 3.9 3.10 3.11 3.12)' \
        '--no-vscode[Don'\''t install VSCode extensions]' \
        '--no-git[Don'\''t configure Git]' \
        '--no-github-actions[Don'\''t configure GitHub Actions]' \
        '--no-venv[Don'\''t create virtual environment]' \
        '--venv-tool[Virtual environment tool]:tool:(auto uv venv)' \
        '--existing[Configure current directory]' \
        '*:project name:_directories'
}

_python_project_verify() {
    _arguments \
        '(--help -h)'{--help,-h}'[Show help message]'
}

_spp_new() {
    _arguments \
        '1:project name:' \
        '2:python version:(3.8 3.9 3.10 3.11 3.12)'
}

_spp_cd() {
    _arguments \
        '1:project name:' \
        '2:python version:(3.8 3.9 3.10 3.11 3.12)'
}

# Register completions
compdef _python_project_setup python-project-setup
compdef _python_project_verify python-project-verify
compdef _python_project_setup spp
compdef _python_project_setup pps
compdef _python_project_setup spp-quick
compdef _python_project_setup spp-minimal
compdef _python_project_setup spp-uv
compdef _python_project_setup spp-existing
compdef _python_project_setup spp38
compdef _python_project_setup spp39
compdef _python_project_setup spp310
compdef _python_project_setup spp311
compdef _python_project_setup spp312
compdef _spp_new spp-new
compdef _spp_cd spp-cd

# Show completion help
if [[ "${funcstack[1]}" != "${0}" ]]; then
    echo "🔧 Zsh completion for Python Project Setup loaded!"
fi