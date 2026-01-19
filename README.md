<p align="center">
<a href='https://ko-fi.com/Z8Z2CHALG' target='_blank'><img height='42' style='border:0px;height:42px;' src='https://storage.ko-fi.com/cdn/kofi3.png?v=3' alt='Buy Me a Coffee at ko-fi.com' /></a>
</p>

# Simple Package Tool (SPT)

A streamlined command-line tool for creating Debian packages from GitHub repositories.

[Read more about Debian packaging](https://betterprogramming.pub/how-to-create-a-basic-debian-package-927be001ad80)

## Table of Contents

- [Simple Package Tool (SPT)](#simple-package-tool-spt)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Requirements](#requirements)
    - [Essential](#essential)
    - [Recommended](#recommended)
    - [Quick Setup](#quick-setup)
  - [Installation](#installation)
  - [Quick Start](#quick-start)
  - [Commands](#commands)
    - [`spt create [options] username/repo`](#spt-create-options-usernamerepo)
    - [`spt generate [options]`](#spt-generate-options)
    - [`spt install`](#spt-install)
    - [`spt open`](#spt-open)
    - [`spt list`](#spt-list)
    - [`spt clean [options]`](#spt-clean-options)
  - [Workflow](#workflow)
  - [Repository Structure](#repository-structure)
  - [Package Structure](#package-structure)
  - [Customizing Packages](#customizing-packages)
    - [Adding Dependencies](#adding-dependencies)
    - [Common Dependencies](#common-dependencies)
  - [Troubleshooting](#troubleshooting)
    - ["Could not find repository or it has no releases"](#could-not-find-repository-or-it-has-no-releases)
    - ["Unable to clone repository"](#unable-to-clone-repository)
    - ["Missing DEBIAN/control file"](#missing-debiancontrol-file)
    - [Package fails lintian checks](#package-fails-lintian-checks)
  - [Bash Completion](#bash-completion)
  - [Man Pages](#man-pages)
  - [Testing](#testing)
  - [Tips](#tips)
  - [Examples](#examples)
    - [Complete workflow](#complete-workflow)
    - [CI/CD automation](#cicd-automation)
  - [Contributing](#contributing)
  - [Author](#author)
  - [License](#license)
  - [Changelog](#changelog)
    - [v0.2.0](#v020)
    - [v0.0.9](#v009)

## Features

- 🚀 One-command package creation from GitHub repos
- 🔍 Automatic version detection from releases
- 🏗️ Smart architecture detection
- 📦 VSCode integration for editing
- ✅ Package validation with lintian
- 🔄 HTTPS/SSH fallback for cloning
- 📊 Cache management (list/clean)
- 🎯 Dry-run mode for testing
- 💡 Interactive and automated modes
- ⌨️ Bash completion support

## Requirements

### Essential
- **Linux/Debian** or **macOS** (with Homebrew)
- **curl** - API calls
- **dpkg** - Package building (`brew install dpkg` on macOS)
- **git** - Repository cloning
- **GitHub CLI (gh)** - Authentication ([installation](https://github.com/cli/cli#installation))

### Recommended
- **jq** - Better JSON parsing
- **lintian** - Package validation
- **VSCode** - Package editing

### Quick Setup

```bash
# Debian/Ubuntu
sudo apt install curl dpkg git jq lintian

# macOS (note: gh is already included above)
brew install curl dpkg git jq gh

# Install GitHub CLI on Debian/Ubuntu
# See: https://github.com/cli/cli#installation
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Authenticate with GitHub (both platforms)
gh auth login
```

## Installation

Download from [releases](https://github.com/shinokada/spt/releases):

```bash
# Download latest (replace X.X.X with version)
curl -LO https://github.com/shinokada/spt/releases/download/vX.X.X/spt_X.X.X-X_all.deb

# Install
sudo apt install ./spt_X.X.X-X_all.deb
```

## Quick Start

```bash
# Create package from GitHub repo
spt create username/repo

# Edit dependencies (optional)
spt open  # Opens in VSCode
# Edit DEBIAN/control to add: Depends: bash (>= 4.0), curl

# Generate .deb file
spt generate

# Test locally
spt install
```

## Commands

### `spt create [options] username/repo`

Creates a pre-package from a GitHub repository.

**Options:**
- `-c, --code` - Open in VSCode after creation
- `-y, --yes` - Skip interactive prompts
- `-h, --help` - Show help

**Example:**
```bash
spt create shinokada/teffects
spt create -cy username/repo  # Non-interactive + open in VSCode
```

### `spt generate [options]`

Generates a .deb package from the pre-package.

**Options:**
- `-d, --dry-run` - Preview without building
- `-o, --output DIR` - Custom output directory
- `-h, --help` - Show help

**Example:**
```bash
spt generate
spt generate --dry-run  # Test first
spt generate -o /tmp/packages  # Custom location
```

### `spt install`

Installs the generated .deb package locally.

```bash
spt install
```

### `spt open`

Opens the pre-package in VSCode (or $EDITOR).

```bash
spt open
```

### `spt list`

Lists all cached packages (pre-packages and .deb files).

```bash
spt list
```

### `spt clean [options]`

Cleans the cache directory.

**Options:**
- `-f, --force` - Skip confirmation

```bash
spt clean
spt clean -f  # Force clean
```

## Workflow

```bash
# 1. Create pre-package
spt create username/repo

# 2. Edit dependencies (DEBIAN/control)
spt open
# Add: Depends: bash (>= 4.0), curl, jq

# 3. Generate .deb
spt generate

# 4. Test locally
spt install

# 5. Distribute via GitHub releases
gh release create v1.0.0 ~/.cache/spt/deb/*.deb
```

## Repository Structure

Your GitHub repository should be structured like this:

```text
your-repo/
├── repo-name          # Main executable (same name as repo)
├── lib/              # Supporting files (optional)
│   ├── module1.sh
│   └── module2.sh
├── README.md
└── LICENSE
```

**Important:**
- Main executable must match repository name
- It will be installed to `/usr/bin/`
- Supporting files go to `/usr/share/repo-name/`
- Update script paths to reference `/usr/share/repo-name/`:

```bash
# In your main script
script_dir="/usr/share/repo-name"
source "$script_dir/lib/module.sh"
```

## Package Structure

SPT creates this structure:

```text
~/.cache/spt/
├── pkg/              # Pre-packages (editable)
│   └── repo_1.0.0-1_all/
│       ├── DEBIAN/
│       │   ├── control
│       │   └── preinst
│       └── usr/
│           ├── bin/repo
│           └── share/repo/
└── deb/              # Generated .deb files
    └── repo_1.0.0-1_all.deb
```

## Customizing Packages

### Adding Dependencies

Edit `DEBIAN/control` after running `spt create`:

```text
Package: myapp
Version: 1.0.0
Architecture: all
Maintainer: Your Name <your@email.com>
Depends: bash (>= 4.0), curl, jq
Homepage: https://github.com/username/myapp
Description: Short description
 Longer description here.
 Multiple lines supported.
```

### Common Dependencies

```text
Depends: bash (>= 4.0)                    # For bash scripts
Depends: bash (>= 4.0), curl, jq, git    # With external tools
```

## Troubleshooting

### "Could not find repository or it has no releases"
- Ensure repository has at least one release with a version tag (v1.0.0 or 1.0.0)
- Check repository is public or you're authenticated with `gh auth status`

### "Unable to clone repository"
- Run `gh auth login` to authenticate
- Verify repository exists and is accessible

### "Missing DEBIAN/control file"
```bash
spt clean
spt create username/repo
```

### Package fails lintian checks
- Edit pre-package: `spt open`
- Add missing dependencies to `DEBIAN/control`
- Check file permissions are correct

## Bash Completion

Install completion support:

```bash
# System-wide
sudo cp completions/spt-completion.bash /etc/bash_completion.d/spt

# User-only
mkdir -p ~/.local/share/bash-completion/completions
cp completions/spt-completion.bash ~/.local/share/bash-completion/completions/spt

# Reload shell
source ~/.bashrc
```

Usage:
```bash
spt <TAB>              # Shows commands
spt create -<TAB>      # Shows flags
```

## Man Pages

```bash
# Install
sudo cp man/spt.1 /usr/share/man/man1/
sudo mandb

# View
man spt

# Or view without installing
man ./man/spt.1
```

## Testing

```bash
# Run unit tests
./tests/run_tests.sh

# Run integration tests
./tests/integration_tests.sh
```

See `tests/README.md` for details.

## Tips

1. Install `jq` for better error messages and reliability
2. Always test with `spt install` before distributing
3. Use semantic versioning for releases (v1.0.0, v1.0.1, etc.)
4. Run `spt generate --dry-run` to preview before building
5. Clean cache regularly with `spt clean`

## Examples

### Complete workflow
```bash
# Create and open in VSCode
spt create -c username/awesome-tool

# Edit DEBIAN/control, add dependencies
# Depends: bash (>= 4.0), curl, jq

# Preview
spt generate --dry-run

# Build
spt generate

# Test
spt install

# List packages
spt list
```

### CI/CD automation
```bash
# Non-interactive mode
spt create -y username/repo
spt generate -o ./dist
```

## Contributing

Contributions welcome! See `CONTRIBUTING.md` for guidelines.

## Author

Shinichi Okada

## License

See LICENSE file.

## Changelog

### v0.2.0
- Added `list` and `clean` commands
- Added `--yes` flag for non-interactive mode
- Added `--dry-run` and `--output` options
- Improved error messages and validation
- Added HTTPS/SSH fallback for cloning
- Added automatic architecture detection
- Enhanced lintian integration
- Better JSON parsing with jq support
- Removed unnecessary sudo requirements

### v0.0.9
- Initial release
- Basic create, generate, and install commands
