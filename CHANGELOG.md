# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-01-15

### Added
- **New Commands:**
  - `spt list` - List all cached pre-packages and .deb files with metadata
  - `spt clean` - Clean cache directory with confirmation prompt
  - `spt open` - Open pre-package in VSCode

- **New Flags:**
  - `--yes` / `-y` flag for create command to skip interactive prompts
  - `--dry-run` / `-d` flag for generate command to preview without building
  - `--force` / `-f` flag for clean command to skip confirmation
  - `--output` / `-o` option for generate command to specify custom output directory
  - `--code` / `-c` flag for create command to auto-open in VSCode

- **Features:**
  - HTTPS/SSH fallback for git clone (tries HTTPS first, falls back to SSH)
  - Automatic architecture detection using `dpkg --print-architecture`
  - JSON parsing with jq when available (more reliable than grep)
  - Automatic main script detection with fallback to manual selection
  - Package validation and structure checking before building
  - Lintian integration for package quality checks (when installed)
  - Detection and warning for .git directories in packages
  - Version validation to catch missing or invalid releases
  - Already-installed package detection in install command
  - Detailed package information display (version, size, architecture)
  - Progress indicators and improved user feedback
  - Comprehensive error messages with actionable solutions

- **Testing & Quality:**
  - Automated unit test suite (`tests/run_tests.sh`)
  - Integration test suite (`tests/integration_tests.sh`)
  - GitHub Actions CI/CD workflows
  - ShellCheck compliance throughout codebase
  - Test coverage for all commands and error scenarios

- **Developer Experience:**
  - Bash completion for all commands and flags
  - Comprehensive man pages (spt.1)
  - GitHub Actions workflows for CI and releases
  - Test documentation and examples

### Changed
- **Improved User Experience:**
  - Removed unnecessary `sudo` requirements for cache directory operations
  - Better error messages with specific solutions
  - Cleaner output with emojis and formatting
  - Consistent exit codes and error handling
  - More informative success messages with next steps
  - Better handling of edge cases (missing files, invalid repos, etc.)

- **Code Quality:**
  - Consistent quoting throughout all scripts
  - Better variable validation and safety checks
  - Improved function organization and modularity
  - Added comprehensive comments and documentation
  - Fixed shellcheck warnings and suggestions

- **Reliability:**
  - Robust JSON parsing with fallback methods
  - Better network error handling
  - Validation of package structure before building
  - Graceful handling of missing optional tools (jq, lintian)
  - Protection against corrupted or incomplete packages

### Fixed
- SSH-only users can now clone repositories (HTTPS fallback)
- Cache directory no longer requires sudo for cleanup
- Better handling of repositories without releases
- Fixed architecture hardcoding (now auto-detects)
- Main script detection works with non-standard names
- Proper handling of spaces and special characters in paths
- Consistent exit codes across all commands

### Documentation
- Complete rewrite of README.md with:
  - Quick start guide
  - Detailed command documentation
  - Workflow examples
  - Repository structure requirements
  - Troubleshooting section
  - CI/CD integration examples
  - Tips and best practices
  - Bash completion instructions
  - Man page installation
  - Testing guide
- Added TROUBLESHOOTING.md with comprehensive solutions
- Added CONTRIBUTING.md with development guidelines
- Added CHANGELOG.md with version history
- Added INSTALL.md with quick setup guide
- Added IMPROVEMENTS.md with summary of changes
- Added tests/README.md with testing documentation
- Added inline help text for all commands
- Improved command examples in help output
- Man pages in standard format
- Example configuration file template

## [0.0.9] - 2024-01-01

### Added
- Initial release
- Basic package creation from GitHub repositories
- `spt create` command to create pre-packages
- `spt generate` command to build .deb files
- `spt install` command to install packages locally
- Interactive prompts for package metadata
- GitHub API integration for version detection
- Repository description fetching
- Automatic DEBIAN/control file generation
- Pre-installation script generation (preinst)
- Package structure creation with proper permissions

### Features
- Support for username/repo format
- GitHub CLI authentication check
- Package caching in ~/.cache/spt
- VSCode integration for package editing
- Git config integration for maintainer info
- Automatic version extraction from releases

## [Unreleased]

### Planned
- Configuration file support (~/.sptrc)
- Multiple package management (batch operations)
- Template system for common package types
- Package signing support
- Release automation helpers
- Test suite and validation framework
- Man page generation
- Bash completion support
- Support for other package formats (RPM, Arch)
- GitHub Actions workflow generator
- Package repository management
- Dependency resolution improvements

### Ideas
- Interactive package editor (TUI)
- Package comparison and diff tools
- Automated testing before installation
- Integration with popular CI/CD platforms
- Package statistics and analytics
- Collaboration features for teams
- Cloud storage integration
- Package versioning and rollback
- Multi-architecture builds
- Cross-compilation support

---

## Version History

- **0.2.0** - Major feature release with new commands and improvements
- **0.0.9** - Initial release with basic functionality

## Migration Notes

### Upgrading from 0.0.9 to 0.2.0

No breaking changes. All existing workflows will continue to work.

**New features you can start using:**
```bash
# Skip interactive prompts in scripts
spt create -y username/repo

# Preview before building
spt generate --dry-run

# See what you've built
spt list

# Clean up easily
spt clean -f
```

**Recommended actions after upgrade:**
1. Install jq for better reliability: `sudo apt install jq`
2. Install lintian for package validation: `sudo apt install lintian`
3. Try the new list command: `spt list`
4. Read the updated README for new features

## Contributing

See the main README.md for contribution guidelines.

## Links

- [Repository](https://github.com/shinokada/spt)
- [Issues](https://github.com/shinokada/spt/issues)
- [Releases](https://github.com/shinokada/spt/releases)
