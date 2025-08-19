# Python Project Setup Tools

A comprehensive set of bash scripts to quickly set up Python projects with modern development tools and best practices.

## 🚀 Quick Start

### Option 1: Install System-Wide (Recommended)

```bash
# Clone or download this repository
git clone https://github.com/halprez/dev_tools
cd dev_tools

# Install the tools system-wide
./install.sh

# Now you can use them from anywhere
python-project-setup my-awesome-project
```

### Option 2: Direct Script Usage

```bash
# Clone or download this repository
git clone https://github.com/halprez/dev_tools
cd dev_tools

# Set up a new Python project
./scripts/setup_python_project.sh my-awesome-project

# Or configure an existing directory
cd my-existing-project
/path/to/dev_tools/scripts/setup_python_project.sh --existing
```

## 📦 Installation

### Automatic Installation

The `install.sh` script provides easy system-wide installation:

```bash
# Clone the repository
git clone https://github.com/halprez/dev_tools
cd dev_tools

# Install to ~/.local/bin (default, no sudo needed)
./install.sh

# Or install system-wide to /usr/local/bin (requires sudo)
./install.sh --system

# Install with convenient shell shortcuts (spp, ppv, etc.)
./install.sh --shell-integration

# Install with global Claude Code configuration
./install.sh --claude-config

# Full installation with all features
./install.sh --shell-integration --claude-config

# Check installation status
./install.sh --check

# Uninstall if needed
./install.sh --uninstall
```

### Manual Installation

If you prefer manual installation:

```bash
# Add to your PATH in ~/.bashrc or ~/.zshrc
export PATH="/path/to/dev_tools/scripts:$PATH"

# Or create symlinks
ln -s /path/to/dev_tools/scripts/setup_python_project.sh ~/.local/bin/python-project-setup
ln -s /path/to/dev_tools/scripts/08_verify_setup.sh ~/.local/bin/python-project-verify
```

### Installed Commands

After installation, you get these commands:

- **`python-project-setup`** - Main setup command for creating/configuring Python projects
- **`python-project-verify`** - Verify existing project setup
- **`claude-config`** - Manage Claude Code configurations (global and project-specific)

### Shell Shortcuts (Optional)

Install with `--shell-integration` to get convenient aliases and tab completion:

**Quick Commands:**
- **`spp`** - Short for `python-project-setup`
- **`ppv`** - Short for `python-project-verify`
- **`spp-help`** - Show all available shortcuts

**Smart Functions:**
- **`spp-new <name> [version]`** - Create project with specific Python version
- **`spp-cd <name> [version]`** - Create project and cd into it
- **`spp-here`** - Setup current directory as Python project
- **`activate`** - Activate project's virtual environment

**Quick Variants:**
- **`spp-quick`** - No VSCode, no Git setup
- **`spp-minimal`** - Minimal setup (no VSCode, Git, or GitHub Actions)
- **`spp-uv`** - Use uv for package management
- **`spp38, spp39, spp310, spp311, spp312`** - Python version shortcuts

**Development Shortcuts:**
- **`mqc`** - `make quality-check`
- **`mtest`** - `make test`
- **`mfix`** - `make fix`
- **`mlint`** - `make lint`
- **`minstall`** - `make install-dev`

### Claude Code Integration (Optional)

Install with `--claude-config` to get Claude Code configuration management:

**Configuration Commands:**
- **`claude-config`** - Full configuration management
- **`claude-status`** - Check configuration status
- **`claude-global`** - Install global configuration
- **`claude-project`** - Install project-specific configuration

**What Gets Configured:**
- **Global CLAUDE.md** at `~/.claude/CLAUDE.md` - Used by Claude Code for all projects
- **Project-specific** configurations in `claude/CLAUDE.md` for individual projects
- **Best practices** for Python development, SOLID principles, and clean code
- **Automatic backup** of existing configurations

## 📦 What Gets Installed

### Development Tools
- **Ruff** - Lightning-fast Python linter and formatter
- **Pytest** - Modern testing framework with coverage reporting
- **Pre-commit** - Git hooks for code quality enforcement

### Installer vs Project Setup

**Installer (One-time setup):**
- **Commands** - `python-project-setup`, `python-project-verify`, `claude-config`
- **Shell shortcuts** - `spp`, `ppv`, `spp-new`, etc. (optional)
- **VSCode extensions** - Global extensions for all projects (optional)
- **Claude configuration** - Global `~/.claude/CLAUDE.md` (optional)

**Project Setup (Per project):**
- **Project structure** - src/, tests/, docs/, claude/
- **Configuration files** - pyproject.toml, Makefile, .pre-commit-config.yaml
- **VSCode project config** - .vscode/settings.json, launch.json, tasks.json (optional with `--vscode`)  
- **GitHub Actions** - CI/CD workflow (optional with `--github-actions`)
- **Claude project config** - claude/CLAUDE.md (automatic)

### Core Project Structure
```
my-project/
├── src/my-project/          # Source code
├── tests/                   # Test files
├── docs/                    # Documentation
├── claude/                  # Claude Code configuration (automatic)
├── pyproject.toml          # Project configuration
├── Makefile                # Development commands
├── .gitignore              # Git ignore rules
└── README.md               # Project documentation
```

### Optional Components (Flag-dependent)
```
├── .vscode/                 # VSCode configuration (--vscode)
│   ├── settings.json        # Python interpreter, Ruff settings
│   ├── launch.json          # Debug configurations
│   └── tasks.json           # Make command shortcuts
├── .github/workflows/       # GitHub Actions CI/CD (--github-actions)
│   └── ci.yml               # Multi-Python testing workflow
└── .pre-commit-config.yaml  # Code quality hooks (with Git setup)
```

### Configuration Files
- **pyproject.toml** - Modern Python project configuration with Ruff settings
- **Makefile** - Easy-to-use development commands
- **.pre-commit-config.yaml** - Automated code quality checks
- **.vscode/settings.json** - VSCode Python development settings
- **.github/workflows/ci.yml** - GitHub Actions for CI/CD

## 🛠️ Usage Options

### Basic Usage

With installed commands:
```bash
# Create new project with defaults
python-project-setup my-project

# Specify Python version
python-project-setup --python 3.11 my-project

# Use specific virtual environment tool
python-project-setup --venv-tool uv my-project
```

With shell shortcuts (if `--shell-integration` was used):
```bash
# Quick project creation
spp my-project

# Create with Python version and enter directory
spp-cd my-app 3.12

# Setup current directory
spp-here

# Use uv for faster package management
spp-uv my-fast-project

# Minimal setup for simple scripts
spp-minimal my-script
```

Or with direct script usage:
```bash
# Create new project with defaults
./scripts/setup_python_project.sh my-project

# Specify Python version
./scripts/setup_python_project.sh --python 3.11 my-project

# Use specific virtual environment tool
./scripts/setup_python_project.sh --venv-tool uv my-project
```

### Advanced Options
```bash
python-project-setup [OPTIONS] [PROJECT_NAME]

OPTIONS:
    -h, --help              Show help message
    -n, --name NAME         Project name
    -p, --python VERSION    Python version (default: 3.11)
    --vscode              Create VSCode configuration files (default: off)
    --no-git              Don't configure Git
    --github-actions      Configure GitHub Actions workflow (default: off)
    --no-venv             Don't create virtual environment
    --venv-tool TOOL      Virtual environment tool: venv, uv, auto
    --existing            Configure current directory
```

### Examples
```bash
# Basic setup (minimal, clean)
python-project-setup my-project

# With VSCode configuration  
python-project-setup --vscode my-project

# Use uv for faster package management
python-project-setup --venv-tool uv my-project

# With GitHub Actions workflow
python-project-setup --github-actions my-project

# Full-featured project
python-project-setup --vscode --github-actions my-project

# Configure existing project directory
cd my-existing-project
python-project-setup --existing

# Verify an existing project setup
python-project-verify

# Shell shortcut examples (with --shell-integration)
spp my-web-app                    # Quick setup
spp-new api-service 3.12          # With Python version  
spp-cd ml-project                 # Create and enter
spp-uv fast-app                   # Use uv package manager
cd existing && spp-here           # Setup current directory
ppv                               # Quick verify

# Note: GitHub Actions and VSCode extensions handled separately
python-project-setup --github-actions my-project  # Add CI/CD
./install.sh --vscode-extensions                   # Install extensions once

# Claude Code configuration examples (with --claude-config)
claude-config status              # Check current config
claude-global                     # Install global Claude config
claude-project                    # Add Claude config to current project
```

## 🔧 Development Commands

After setup, use these Makefile commands in your project:

```bash
make help              # Show all available commands
make install-dev       # Install development dependencies
make test              # Run tests with coverage
make lint              # Check code quality with Ruff
make format            # Format code with Ruff
make fix               # Auto-fix linting issues
make quality-check     # Run all quality checks
make clean             # Remove cache files
```

## 📋 Script Details

The setup process runs these scripts in sequence:

1. **01_check_dependencies.sh** - Verify required tools (Python, uv/venv, Git, VSCode)
2. **02_create_structure.sh** - Create project directory structure and basic files
3. **03_create_venv.sh** - Create and configure virtual environment
4. **04_create_configs.sh** - Generate configuration files (pyproject.toml, Makefile, etc.)
5. **05_install_deps.sh** - Install Python dependencies
6. **06_setup_git.sh** - Initialize Git repository and install pre-commit hooks
7. **07_install_vscode.sh** - Install recommended VSCode extensions
8. **08_verify_setup.sh** - Verify everything works correctly
9. **09_show_summary.sh** - Display setup summary and next steps

## 🎯 VSCode Integration

The setup configures VSCode with:

### Recommended Extensions
- **Python** (ms-python.python) - Core Python support
- **Ruff** (charliermarsh.ruff) - Linting and formatting
- **GitLens** (eamodio.gitlens) - Enhanced Git integration
- **Python Docstring Generator** (njpwerner.autodocstring) - Auto-generate docstrings
- **Jupyter** (ms-toolsai.jupyter) - Notebook support

### VSCode Configuration
- Python interpreter set to project virtual environment
- Ruff enabled for linting and formatting
- Format on save enabled
- Auto-fix imports and linting issues
- Test discovery configured for pytest

### Quick VSCode Setup
```bash
# Open project in VSCode
code .

# Select Python interpreter
# Ctrl+Shift+P → "Python: Select Interpreter"
# Choose: ./.venv/bin/python
```

## 🔄 Git Workflow

The setup includes Git configuration with:

- **.gitignore** - Python-specific ignore patterns
- **Pre-commit hooks** - Automatic code quality checks
- **Initial commit** - Ready-to-push first commit

## 🧪 Testing Setup

Pytest is configured with:

- **Coverage reporting** - HTML and terminal coverage reports
- **Test discovery** - Automatic test file detection
- **Example tests** - Sample test file to get started

### Test Commands
```bash
make test                     # Run all tests with coverage
pytest tests/                 # Run tests directly
pytest tests/test_example.py  # Run specific test file
pytest --cov-report=html      # Generate HTML coverage report
```

## 📊 Code Quality

Ruff is configured for:

- **Linting** - Multiple rule sets (pycodestyle, pyflakes, isort, etc.)
- **Formatting** - Black-compatible code formatting
- **Import sorting** - Automatic import organization
- **SOLID principles** - Rules encouraging good design patterns

### Quality Commands
```bash
make lint                     # Check code quality
make format                   # Format code
make fix                      # Auto-fix issues
make quality-check            # Run complete quality check
```

## 🚀 CI/CD with GitHub Actions

Optional GitHub Actions workflow includes:

- **Multi-Python testing** - Test on Python 3.8-3.12
- **Code quality checks** - Ruff linting and formatting
- **Coverage reporting** - Upload to Codecov
- **Automated testing** - Run on push and pull requests

## 🤖 Claude Code Integration

This toolkit includes comprehensive Claude Code configuration management:

### Automatic Project Configuration
- **New projects** automatically include `claude/CLAUDE.md` with Python best practices
- **Existing projects** can add Claude configuration with `claude-project` command
- **Consistent setup** across all your Python projects

### Global Configuration Management
```bash
# Install global Claude configuration (affects all projects)
claude-config install-global

# Check current configuration status
claude-config status

# Compare configurations
claude-config diff

# Backup and restore
claude-config backup-global
claude-config restore-global
```

### Best Practices Included
The Claude configuration includes:
- **SOLID principles** and clean code guidelines
- **Python-specific** development patterns
- **Testing and quality** best practices
- **Project structure** recommendations
- **Code review** and refactoring guidance

## 🔧 Requirements

### Required
- **Python 3.8+** - Core Python interpreter
- **pip** - Python package installer

### Optional
- **uv** - Fast Python package manager (recommended)
- **Git** - Version control
- **VSCode** - Code editor with extension support
- **pre-commit** - Git hooks (installed automatically)

### Installing uv (Recommended)
```bash
# Install uv for faster package management
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## 🛠️ Troubleshooting

### Common Issues

**Virtual environment creation fails:**
```bash
# Ensure Python is available
python3 --version
# Or install uv for better environment management
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**VSCode extensions fail to install:**
```bash
# Ensure VSCode CLI is available
code --version
# If not available, install VSCode and add to PATH
```

**Pre-commit hooks fail:**
```bash
# Reinstall pre-commit hooks
pre-commit uninstall
pre-commit install
```

**Permission errors:**
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

### Verification

Run the verification script to check your setup:
```bash
# From within your project directory (if installed)
python-project-verify

# Or use direct script path
/path/to/dev_tools/scripts/08_verify_setup.sh
```

### Installation Issues

**Commands not found after installation:**
```bash
# Check if ~/.local/bin is in your PATH
echo $PATH | grep -o '\.local/bin'

# Add to your shell profile if missing
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Check installation status:**
```bash
# From the dev_tools directory
./install.sh --check
```

## 📝 Customization

### Modifying Tool Configuration

**Ruff settings** - Edit `pyproject.toml` under `[tool.ruff]`
**VSCode settings** - Edit `.vscode/settings.json`
**Pre-commit hooks** - Edit `.pre-commit-config.yaml`
**Makefile commands** - Edit `Makefile`

### Adding Dependencies

```bash
# Add to pyproject.toml
[project]
dependencies = [
    "requests",
    "pandas",
]

[project.optional-dependencies]
dev = [
    "ruff>=0.1.0",
    "pytest>=7.0.0",
    # Add more dev dependencies here
]

# Reinstall
make install-dev
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with a sample project
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Ruff** - For blazing-fast Python tooling
- **Pytest** - For excellent testing framework
- **uv** - For fast Python package management
- **VSCode** - For excellent Python development support
- **Anthropic** - For Claude code