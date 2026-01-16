# Contributing to SPT

Thank you for your interest in contributing to SPT (Simple Package Tool)! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Release Process](#release-process)

## Code of Conduct

Be respectful, constructive, and professional. We're all here to make SPT better.

## Getting Started

1. **Fork the repository**
   ```bash
   gh repo fork shinokada/spt --clone
   cd spt
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**

4. **Test thoroughly**

5. **Submit a pull request**

## Development Setup

### Prerequisites

```bash
# Required
sudo apt install bash git curl dpkg

# For development
sudo apt install shellcheck shfmt

# For testing
sudo apt install bats jq lintian
```

### Local Installation

To test your changes locally without installing:

```bash
# Make the script executable
chmod +x spt

# Run directly
./spt --version

# Or add to PATH temporarily
export PATH="$PWD:$PATH"
spt --version
```

### Project Structure

```text
spt/
├── spt                 # Main executable
├── lib/               # Library modules
│   ├── create.sh     # Create command
│   ├── generate.sh   # Generate command
│   ├── install.sh    # Install command
│   ├── list.sh       # List command
│   ├── clean.sh      # Clean command
│   ├── open.sh       # Open command
│   ├── getoptions.sh # Argument parsing (external)
│   └── utils.sh      # Utility functions
├── README.md         # Main documentation
├── CHANGELOG.md      # Version history
├── TROUBLESHOOTING.md # Troubleshooting guide
├── CONTRIBUTING.md   # This file
└── LICENSE           # License file
```

## How to Contribute

### Reporting Bugs

1. **Check existing issues** to avoid duplicates
2. **Create a new issue** with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - SPT version (`spt --version`)
   - System info (`uname -a`)
   - Relevant error messages

### Suggesting Features

1. **Check existing issues** for similar requests
2. **Create a feature request** with:
   - Clear use case
   - Proposed solution
   - Alternative approaches considered
   - Potential impact

### Contributing Code

Areas where contributions are welcome:

- **Bug fixes** - Always appreciated!
- **New commands** - Extend functionality
- **Improved error handling** - Better user experience
- **Documentation** - Always needs improvement
- **Tests** - Help ensure reliability
- **Performance** - Optimizations welcome

## Coding Standards

### Shell Script Standards

Follow these conventions for consistency:

#### 1. Bash Style

```bash
# Use #!/usr/bin/env bash
#!/usr/bin/env bash

# Enable strict mode
set -eu

# Use long flags for clarity
if [ "$VERBOSE" = 1 ]; then
    echo "Verbose mode enabled"
fi

# Quote variables
echo "Processing: $FILE_NAME"
rm -rf "${CACHE_DIR:?}/"*

# Use functions for organization
fn_process_file() {
    local file=$1
    # ... function body ...
}
```

#### 2. Naming Conventions

```bash
# Functions: fn_snake_case
fn_create_package() { }

# Variables: UPPER_CASE for globals
DEBTEMP_DIR="$HOME/.cache/spt"

# Variables: lower_case for locals
local file_name="package.deb"

# Constants: UPPER_CASE
readonly VERSION="0.2.0"
```

#### 3. Error Handling

```bash
# Always check command success
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq not found"
    exit 1
fi

# Use || for fallback
git clone https://github.com/user/repo.git 2>/dev/null || \
    git clone git@github.com:user/repo.git

# Provide helpful error messages
echo "Error: Could not find repository"
echo "Please ensure:"
echo "  1. Repository exists and is accessible"
echo "  2. You have proper authentication"
exit 1
```

#### 4. User Feedback

```bash
# Clear progress indicators
echo "Creating package structure ..."

# Success messages with checkmark
echo "✓ Package created successfully!"

# Show next steps
echo ""
echo "Next steps:"
echo "  1. Review the package"
echo "  2. Run 'spt generate'"
```

#### 5. Comments

```bash
# Comment above, not inline (except for clarity)
# This creates the control file
cat <<EOF >"$CONTROL_FILE"
Package: ${PACKAGE_NAME}
EOF

# Use clear variable names to reduce need for comments
package_size=$(du -sh "$package_dir" | cut -f1)  # Clear without comment
```

### Code Quality Tools

#### ShellCheck

Always run shellcheck before committing:

```bash
# Check main script
shellcheck spt

# Check all lib files
shellcheck lib/*.sh

# Or check everything
find . -name "*.sh" -exec shellcheck {} \;
```

Common shellcheck directives used in SPT:

```bash
# Disable SC2034 (unused variable) for shared variables
# shellcheck disable=SC2034
VERSION="0.2.0"

# Disable SC1091 (can't follow source) for dynamic sourcing
# shellcheck disable=SC1091
. "${script_dir}/lib/utils.sh"
```

#### shfmt

Format shell scripts consistently:

```bash
# Format with 4-space indentation
shfmt -i 4 -w spt lib/*.sh

# Check formatting
shfmt -i 4 -d spt lib/*.sh
```

## Testing

### Manual Testing

Test all commands:

```bash
# Test create
spt create shinokada/teffects
spt create -y shinokada/teffects
spt create -c shinokada/teffects

# Test generate
spt generate
spt generate --dry-run
spt generate -o /tmp/test

# Test other commands
spt list
spt open
spt install
spt clean
spt clean -f
```

### Test Coverage

When adding features, test:

1. **Happy path** - Normal usage
2. **Error cases** - Missing files, bad input
3. **Edge cases** - Empty repos, special characters
4. **Flags** - All combinations of flags
5. **Permissions** - With/without sudo
6. **Dependencies** - With/without optional tools

### Example Test Repositories

Use these for testing:

```bash
# Small, simple repo
spt create shinokada/awesome-cli-bins

# Repo with complex structure
spt create shinokada/teffects

# Your own test repo
spt create yourusername/test-package
```

## Submitting Changes

### Pull Request Process

1. **Update documentation**
   - Update README.md if adding features
   - Add entry to CHANGELOG.md
   - Update help text in command files

2. **Ensure code quality**
   ```bash
   # Run shellcheck
   shellcheck spt lib/*.sh
   
   # Format code
   shfmt -i 4 -w spt lib/*.sh
   ```

3. **Test thoroughly**
   - Test all affected commands
   - Verify on clean system if possible
   - Check for regressions

4. **Commit with clear messages**
   ```bash
   # Good commit messages
   git commit -m "Add --dry-run flag to generate command"
   git commit -m "Fix: Handle repositories with no releases"
   git commit -m "Docs: Update README with new examples"
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   gh pr create --fill
   ```

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested manually
- [ ] Added/updated tests
- [ ] Ran shellcheck
- [ ] Updated documentation

## Related Issues
Fixes #123
```

## Release Process

For maintainers:

1. **Update version numbers**
   ```bash
   # Update VERSION in spt
   VERSION="0.2.0"
   
   # Update CHANGELOG.md
   # Add release date and notes
   ```

2. **Create and test package**
   ```bash
   spt create -y shinokada/spt
   spt generate
   spt install
   spt --version  # Verify
   ```

3. **Tag and release**
   ```bash
   git tag -a v0.2.0 -m "Release v0.2.0"
   git push origin v0.2.0
   
   # Create GitHub release
   gh release create v0.2.0 \
     --title "v0.2.0" \
     --notes "$(cat CHANGELOG.md | sed -n '/## \[0.2.0\]/,/## \[0.2.0\]/p' | head -n -1)" \
     ~/.cache/spt/deb/*.deb
   ```

## Areas for Contribution

### High Priority

- [x] Comprehensive test suite ✅ (see tests/)
- [x] GitHub Actions CI/CD workflow ✅ (see .github/workflows/)
- [x] Man page ✅ (see man/spt.1)
- [x] Bash completion script ✅ (see completions/)
- [ ] Package signing support
- [ ] Better dependency resolution

### Medium Priority

- [ ] Configuration file support (~/.sptrc)
- [ ] Multiple package management
- [ ] Template system
- [ ] Package comparison tools
- [ ] RPM package support
- [ ] Cross-architecture builds

### Nice to Have

- [ ] TUI for package editing
- [ ] Package statistics
- [ ] Cloud storage integration
- [ ] Team collaboration features
- [ ] Package marketplace
- [ ] Docker integration

## Questions?

- Create an issue for questions
- Check existing issues and discussions
- Read the documentation thoroughly

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

## Acknowledgments

Thank you for contributing to SPT! Every contribution, big or small, helps make this tool better for everyone.
