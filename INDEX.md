# SPT Documentation Index

Welcome to the SPT (Simple Package Tool) documentation. This index will help you find what you need quickly.

## 📚 Quick Navigation

### Getting Started
- **[README.md](README.md)** - Start here! Complete guide with examples
- **[INSTALL.md](INSTALL.md)** - Quick installation and testing guide
- **[CHANGELOG.md](CHANGELOG.md)** - What's new in each version

### Using SPT
- **[README.md#quick-start](README.md#quick-start)** - Get started in 3 commands
- **[README.md#commands](README.md#commands)** - All command documentation
- **[README.md#workflow](README.md#workflow)** - Step-by-step workflow
- **[README.md#examples](README.md#examples)** - Usage examples

### Troubleshooting
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - 30+ solutions to common issues
- **[README.md#troubleshooting](README.md#troubleshooting)** - Quick fixes
- **[tests/README.md](tests/README.md#troubleshooting)** - Test-specific issues

### Contributing
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
- **[CONTRIBUTING.md#coding-standards](CONTRIBUTING.md#coding-standards)** - Code style guide
- **[CONTRIBUTING.md#testing](CONTRIBUTING.md#testing)** - How to test

### Reference
- **[man/spt.1](man/spt.1)** - Man page (use: `man ./man/spt.1`)
- **[completions/spt-completion.bash](completions/spt-completion.bash)** - Bash completion
- **[config.example](config.example)** - Configuration example

### Development
- **[tests/README.md](tests/README.md)** - Testing documentation
- **[.github/workflows/ci.yml](.github/workflows/ci.yml)** - CI workflow
- **[.github/workflows/release.yml](.github/workflows/release.yml)** - Release workflow

### Summaries
- **[IMPROVEMENTS.md](IMPROVEMENTS.md)** - All improvements made in v0.2.0
- **[COMPLETE.md](COMPLETE.md)** - Verification that everything is implemented

---

## 📖 Documentation by Topic

### Installation

| Document                                         | What's Inside                |
| ------------------------------------------------ | ---------------------------- |
| [README.md#installation](README.md#installation) | Installing from .deb package |
| [INSTALL.md](INSTALL.md)                         | Testing without installing   |
| [README.md#requirements](README.md#requirements) | Dependencies needed          |

### Commands

| Command    | Documentation                                    |
| ---------- | ------------------------------------------------ |
| `create`   | [README.md#spt-create](README.md#spt-create)     |
| `generate` | [README.md#spt-generate](README.md#spt-generate) |
| `install`  | [README.md#spt-install](README.md#spt-install)   |
| `list`     | [README.md#spt-list](README.md#spt-list)         |
| `clean`    | [README.md#spt-clean](README.md#spt-clean)       |
| `open`     | [README.md#spt-open](README.md#spt-open)         |

### Features

| Feature                | Documentation                                                                          |
| ---------------------- | -------------------------------------------------------------------------------------- |
| Bash Completion        | [README.md#bash-completion](README.md#bash-completion)                                 |
| Man Pages              | [README.md#man-pages](README.md#man-pages)                                             |
| Testing                | [README.md#testing](README.md#testing), [tests/README.md](tests/README.md)             |
| CI/CD                  | [README.md#integration-with-github-actions](README.md#integration-with-github-actions) |
| Architecture Detection | [README.md#features](README.md#features)                                               |
| Dry Run                | [README.md#spt-generate](README.md#spt-generate)                                       |

### Troubleshooting

| Issue Type       | Documentation                                                                            |
| ---------------- | ---------------------------------------------------------------------------------------- |
| Installation     | [TROUBLESHOOTING.md#installation-issues](TROUBLESHOOTING.md#installation-issues)         |
| Create Command   | [TROUBLESHOOTING.md#create-command-issues](TROUBLESHOOTING.md#create-command-issues)     |
| Generate Command | [TROUBLESHOOTING.md#generate-command-issues](TROUBLESHOOTING.md#generate-command-issues) |
| Install Command  | [TROUBLESHOOTING.md#install-command-issues](TROUBLESHOOTING.md#install-command-issues)   |
| Testing          | [tests/README.md#troubleshooting](tests/README.md#troubleshooting)                       |

### Development

| Topic           | Documentation                                                                          |
| --------------- | -------------------------------------------------------------------------------------- |
| Setting Up      | [CONTRIBUTING.md#development-setup](CONTRIBUTING.md#development-setup)                 |
| Code Style      | [CONTRIBUTING.md#coding-standards](CONTRIBUTING.md#coding-standards)                   |
| Testing         | [CONTRIBUTING.md#testing](CONTRIBUTING.md#testing), [tests/README.md](tests/README.md) |
| Pull Requests   | [CONTRIBUTING.md#submitting-changes](CONTRIBUTING.md#submitting-changes)               |
| Release Process | [CONTRIBUTING.md#release-process](CONTRIBUTING.md#release-process)                     |

---

## 🎯 Common Tasks

### I want to...

**...create my first package**
→ [README.md#quick-start](README.md#quick-start)

**...understand how SPT works**
→ [README.md#overview](README.md#overview)

**...see examples of using SPT**
→ [README.md#examples](README.md#examples)

**...fix an error I'm getting**
→ [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

**...contribute to SPT**
→ [CONTRIBUTING.md](CONTRIBUTING.md)

**...set up bash completion**
→ [README.md#bash-completion](README.md#bash-completion)

**...read the man page**
→ `man ./man/spt.1` or [man/spt.1](man/spt.1)

**...run tests**
→ [tests/README.md](tests/README.md)

**...understand what changed in v0.2.0**
→ [CHANGELOG.md](CHANGELOG.md) and [IMPROVEMENTS.md](IMPROVEMENTS.md)

**...see if everything is implemented**
→ [COMPLETE.md](COMPLETE.md)

---

## 📝 Document Descriptions

### User Documentation

- **README.md** (13KB) - Main documentation
  - Overview and features
  - Installation instructions
  - Complete command reference
  - Workflow examples
  - Troubleshooting basics
  - Advanced usage
  - Integration examples

- **TROUBLESHOOTING.md** (15KB) - Problem solving
  - Common issues organized by category
  - Step-by-step solutions
  - Debugging tips
  - Quick reference

- **INSTALL.md** (5KB) - Installation guide
  - Development setup
  - Testing without installation
  - Release creation
  - Quick verification

### Developer Documentation

- **CONTRIBUTING.md** (10KB) - Contribution guide
  - How to contribute
  - Code style guide
  - Testing requirements
  - Pull request process
  - Release process

- **tests/README.md** (5KB) - Testing guide
  - Test types and coverage
  - How to run tests
  - How to write tests
  - Test troubleshooting

- **CHANGELOG.md** (6KB) - Version history
  - What's new in each version
  - Breaking changes
  - Migration guides
  - Planned features

### Reference Documentation

- **man/spt.1** (3KB) - Manual page
  - Standard Unix man page
  - Command reference
  - All options documented
  - Examples

- **completions/spt-completion.bash** (3KB) - Bash completion
  - Tab completion script
  - Context-aware suggestions
  - All commands and flags

### Summary Documentation

- **IMPROVEMENTS.md** (8KB) - What changed
  - Before/after comparisons
  - Testing checklist
  - Statistics
  - Priority order

- **COMPLETE.md** (7KB) - Implementation status
  - Verification checklist
  - What's implemented
  - What's planned
  - Final summary

- **INDEX.md** (This file) - Documentation index
  - Quick navigation
  - Topic organization
  - Task-based lookup

---

## 🔍 Search by Keywords

### Keywords → Documents

**automation** → CONTRIBUTING.md, README.md (--yes flag)
**bash completion** → README.md, completions/
**ci/cd** → .github/workflows/, README.md
**contributing** → CONTRIBUTING.md
**dependencies** → README.md#requirements, TROUBLESHOOTING.md
**dry run** → README.md#generate
**error messages** → TROUBLESHOOTING.md
**examples** → README.md#examples
**github** → README.md, .github/workflows/
**installation** → README.md#installation, INSTALL.md
**man pages** → man/, README.md#man-pages
**testing** → tests/, CONTRIBUTING.md#testing
**troubleshooting** → TROUBLESHOOTING.md
**workflow** → README.md#workflow

---

## 📊 Documentation Stats

- **Total documentation files:** 10
- **Total lines of documentation:** ~3,500
- **Total documentation size:** ~100KB
- **Languages:** Markdown, Bash, Man page format
- **Sections in README:** 25+
- **Troubleshooting solutions:** 30+
- **Code examples:** 50+

---

## 🆘 Need Help?

1. **Check README.md first** - Most common questions answered
2. **Search TROUBLESHOOTING.md** - Specific error solutions
3. **Review examples** - See working use cases
4. **Check man page** - Complete reference
5. **Create an issue** - https://github.com/shinokada/spt/issues

---

## 📅 Documentation Maintenance

| Document           | Update Frequency  | Last Updated |
| ------------------ | ----------------- | ------------ |
| README.md          | Every release     | v0.2.0       |
| CHANGELOG.md       | Every release     | v0.2.0       |
| TROUBLESHOOTING.md | As needed         | v0.2.0       |
| CONTRIBUTING.md    | Rarely            | v0.2.0       |
| man/spt.1          | Every release     | v0.2.0       |
| tests/README.md    | With test changes | v0.2.0       |

---

**Last Updated:** January 15, 2026  
**Version:** 0.2.0  
**Maintainer:** Shinichi Okada
