<p align="center">
<a href='https://ko-fi.com/Z8Z2CHALG' target='_blank'><img height='42' style='border:0px;height:42px;' src='https://storage.ko-fi.com/cdn/kofi3.png?v=3' alt='Buy Me a Coffee at ko-fi.com' /></a>
</p>

# Simple Package Tool (SPT)

A streamlined command-line tool for creating Debian packages from GitHub repositories.

## Overview

SPT automates the process of creating basic Debian packages from GitHub repositories. It handles cloning, package structure creation, and .deb generation with sensible defaults and interactive confirmations.

[Read more about creating Debian packages](https://betterprogramming.pub/how-to-create-a-basic-debian-package-927be001ad80)

## Features

- 🚀 **One-command package creation** from GitHub repos
- 🔍 **Automatic version detection** from GitHub releases
- 🏗️ **Smart architecture detection** (falls back to "all")
- 📦 **Pre-package editing** support with VSCode integration
- ✅ **Package validation** with lintian (if installed)
- 🔄 **HTTPS/SSH fallback** for repository cloning
- 📊 **Cache management** with list and clean commands
- 🎯 **Dry-run mode** for safe testing
- 💡 **Interactive and automated** modes (--yes flag)
- 🧪 **Automated test suite** with CI/CD integration
- ⌨️ **Bash completion** for commands and flags
- 📖 **Man pages** for comprehensive documentation

## Requirements

### Essential
- **Linux/Debian** - Primary platform for full functionality
- **macOS** - Supported for development and pre-package creation
  - Install `dpkg` via Homebrew to generate .deb files: `brew install dpkg`
  - Or use [macgnu](https://github.com/shinokada/macgnu) for GNU tools
- **curl** - For API calls
- **dpkg** - For package building
  - Linux: Usually pre-installed
  - macOS: `brew install dpkg`
- **git** - For cloning repositories
- **GitHub CLI (gh)** - For GitHub authentication

### Recommended
- **jq** - For reliable JSON parsing (`sudo apt install jq`)
- **lintian** - For package validation (`sudo apt install lintian`)
- **VSCode** - For editing packages (`code` command)
- **shellcheck** - For development and testing (`sudo apt install shellcheck`)

### Installation of requirements

```bash
# Install essential tools
sudo apt install curl dpkg git

# Install GitHub CLI
# See: https://github.com/cli/cli#installation
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Authenticate with GitHub
gh auth login

# Install recommended tools
sudo apt install jq lintian
```

## Installation

Download the latest Debian package from the [releases](https://github.com/shinokada/spt/releases) page.

```bash
# Download the latest release (replace X with actual version numbers)
curl -LO https://github.com/shinokada/spt/releases/download/vX.X.X/spt_X.X.X-X_all.deb

# Install
sudo apt install ./spt_X.X.X-X_all.deb
```

## Quick Start

```bash
# Create a package
spt create username/repo

# Generate the .deb file
spt generate

# Install locally
spt install
```

## Usage

### Commands

#### `spt create`
Creates a pre-package from a GitHub repository.

```bash
# Basic usage
spt create shinokada/teffects

# Skip interactive prompts
spt create -y username/repo

# Create and open in VSCode
spt create -c username/repo
```

**What it does:**
1. Validates system requirements
2. Fetches repository information from GitHub
3. Auto-detects version from latest release
4. Clones repository (HTTPS with SSH fallback)
5. Creates Debian package structure
6. Generates control files

#### `spt generate`
Generates a .deb package from the pre-package.

```bash
# Generate package
spt generate

# Dry run (preview without building)
spt generate --dry-run

# Custom output directory
spt generate -o /tmp/packages
```

**What it does:**
1. Validates package structure
2. Checks for common issues (.git directory)
3. Builds .deb package with dpkg-deb
4. Runs lintian validation (if available)
5. Shows package information

#### `spt install`
Installs the generated .deb package locally.

```bash
spt install
```

**What it does:**
1. Finds the .deb package in cache
2. Shows package information
3. Checks if already installed
4. Installs with apt (handles dependencies)

#### `spt list`
Lists all cached packages.

```bash
spt list
```

**Shows:**
- Pre-packages (staged)
- Generated .deb packages
- Package metadata (version, arch, size)
- Installation status
- Total cache size

#### `spt clean`
Cleans the cache directory.

```bash
# Interactive clean
spt clean

# Force clean without confirmation
spt clean -f
```

#### `spt open`
Opens the pre-package directory in an editor.

```bash
spt open
```

**What it does:**
1. Finds the first pre-package in the cache
2. Opens it in VSCode if code is available
3. Falls back to $EDITOR if VSCode is not installed

**Notes:**
- Requires an existing pre-package (run spt create first)
- Some files may be owned by root, so editor permission prompts may appear

### Workflow

```bash
# 1. Create pre-package
spt create username/repo

# 2. (Optional) Edit the package
code ~/.cache/spt/pkg/repo_1.0.0-1_all

# 3. Update dependencies in DEBIAN/control
# Edit: ~/.cache/spt/pkg/repo_1.0.0-1_all/DEBIAN/control

# 4. Generate .deb package
spt generate

# 5. Test locally
spt install

# 6. Upload to GitHub releases
# Use gh CLI or web interface

# 7. Users can install from release
# wget <release-url>/package.deb
# sudo apt install ./package.deb
```

## Repository Structure Requirements

Your GitHub repository should follow this structure for SPT to work correctly:

```text
your-repo/
├── repo-name          # Main executable script (same name as repo)
├── lib/              # Supporting library files (optional)
│   ├── module1.sh
│   └── module2.sh
├── README.md
└── LICENSE
```

**Important:**
- The main executable should match the repository name
- The main file will be moved to `/usr/bin`
- Everything else goes to `/usr/share/repo-name`
- The main script should reference libraries using:
```bash
script_dir="/usr/share/repo-name"
source "$script_dir/lib/module.sh"
```

## Package Structure

SPT creates packages with this structure:

```text
repo_1.0.0-1_all/
├── DEBIAN/
│   ├── control       # Package metadata
│   └── preinst       # Pre-installation script
├── usr/
│   ├── bin/
│   │   └── repo      # Main executable
│   └── share/
│       └── repo/     # Supporting files
│           ├── lib/
│           └── ...
```

## Customization

### Editing Control File

After running `spt create`, edit the control file to add dependencies:

```bash
# Open in VSCode
code ~/.cache/spt/pkg/repo_1.0.0-1_all/DEBIAN/control
```

Example control file:

```text
Package: myapp
Version: 1.0.0
Architecture: amd64
Maintainer: Your Name <your@email.com>
Depends: bash (>= 4.0), curl, jq
Homepage: https://github.com/username/myapp
Description: My awesome application
 A longer description can go here.
 Multiple lines are supported.
```

### Common Dependencies

```text
# For bash scripts
Depends: bash (>= 4.0)

# With external tools
Depends: bash (>= 4.0), curl, jq, git

# For specific architecture
Architecture: amd64

# For all architectures
Architecture: all
```

## Cache Location

SPT uses `~/.cache/spt/` for all temporary files:

```text
~/.cache/spt/
├── pkg/              # Pre-packages (editable)
│   └── repo_1.0.0-1_all/
└── deb/              # Generated .deb files
    └── repo_1.0.0-1_all.deb
```

## Troubleshooting

### "Could not find repository or it has no releases"

**Solution:** Ensure the repository:
1. Exists and is public (or you're authenticated)
2. Has at least one release with a version tag
3. Release tag follows semantic versioning (e.g., v1.0.0 or 1.0.0)

### "Unable to clone repository"

**Solutions:**
- Run `gh auth login` to authenticate
- Check if repository is accessible
- Verify SSH keys are set up (if using SSH)

### "Missing DEBIAN/control file"

**Solution:** The pre-package is corrupted. Run:
```bash
spt clean
spt create username/repo
```

### Package fails lintian checks

**Common issues:**
- Missing dependencies in control file
- Incorrect permissions on files
- Missing documentation files

**Fix:** Edit the pre-package before generating:
```bash
code ~/.cache/spt/pkg/your-package/
spt generate
```

### "Not able to create a dir" errors

**Solution:** Check disk space and permissions:
```bash
df -h ~
ls -la ~/.cache/
```

## Examples

### Creating a package with all features

```bash
# Create with VSCode integration
spt create -c username/awesome-tool

# Edit dependencies
# (VSCode opens automatically)
# Edit DEBIAN/control, add:
# Depends: bash (>= 4.0), curl, jq

# Preview before building
spt generate --dry-run

# Build the package
spt generate

# Test installation
spt install

# List everything
spt list

# Clean up when done
spt clean -f
```

### Non-interactive automation

```bash
# Perfect for CI/CD
spt create -y username/repo
spt generate
```

### Custom output directory

```bash
# Generate to specific location
spt generate -o /tmp/releases

# Package is now in /tmp/releases/
ls /tmp/releases/
```

## Tips

1. **Use jq** - Install jq for better error messages and reliability
2. **Test locally first** - Always use `spt install` before distributing
3. **Version your releases** - Use semantic versioning (v1.0.0, v1.0.1, etc.)
4. **Document dependencies** - Keep control file up to date
5. **Check lintian** - Fix warnings before distribution
6. **Clean regularly** - Use `spt clean` to free up space

## Advanced Usage

### Multiple packages

```bash
# Create several packages
spt create user/tool1
spt generate -o ~/packages/tool1

spt create user/tool2  
spt generate -o ~/packages/tool2

# List all
ls ~/packages/
```

## Bash Completion

SPT includes bash completion for commands and flags.

### Installation

**System-wide:**
```bash
sudo cp completions/spt-completion.bash /etc/bash_completion.d/spt
source ~/.bashrc
```

**User-only:**
```bash
mkdir -p ~/.local/share/bash-completion/completions
cp completions/spt-completion.bash ~/.local/share/bash-completion/completions/spt
source ~/.bashrc
```

### Usage

After installation, use Tab to autocomplete:
```bash
spt <TAB>              # Shows: create generate install list clean open
spt create <TAB>       # Shows: -c --code -y --yes -h --help
spt generate -<TAB>    # Shows: -d --dry-run -o --output -h --help
```

## Man Pages

SPT includes comprehensive man pages.

### Installation

```bash
# System-wide
sudo cp man/spt.1 /usr/share/man/man1/
sudo mandb

# View
man spt
```

### Viewing Without Installation

```bash
# View directly
man ./man/spt.1

# Or convert to text
man -l man/spt.1 | col -b > spt-manual.txt
```

## Testing

SPT includes automated test suites.

### Run Unit Tests

```bash
chmod +x tests/run_tests.sh
./tests/run_tests.sh
```

### Run Integration Tests

```bash
chmod +x tests/integration_tests.sh
./tests/integration_tests.sh
```

See `tests/README.md` for detailed testing documentation.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

See `CONTRIBUTING.md` for detailed guidelines.

## Author

Shinichi Okada

## License

Please see LICENSE file.

## Changelog

### v0.2.0
- Added `list` and `clean` commands
- Added `--yes` flag for non-interactive mode
- Added `--dry-run` for generate command
- Added `--output` option for custom output directory
- Improved error messages and validation
- Added HTTPS/SSH fallback for git clone
- Added automatic architecture detection
- Added lintian integration
- Improved package information display
- Better JSON parsing with jq support
- Removed unnecessary sudo requirements
- Enhanced documentation

### v0.0.9
- Initial release
- Basic create, generate, and install commands
