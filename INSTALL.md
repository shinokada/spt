# Quick Installation & Testing Guide

## For Development/Testing

If you want to test the updated SPT without creating a .deb package:

```bash
# Navigate to the spt directory
cd /Users/shinichiokada/Bash/spt

# Make the script executable
chmod +x spt

# Test it works
./spt --version

# Add to PATH temporarily (for this session)
export PATH="$PWD:$PATH"
spt --version

# Or add to PATH permanently in ~/.bashrc or ~/.zshrc
echo 'export PATH="/Users/shinichiokada/Bash/spt:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Creating a Release Package

Once you've tested and are happy with the changes:

```bash
# 1. Make sure you're in a Linux environment
# (This won't work on macOS since dpkg is Linux-only)

# 2. If testing on Linux, create package for SPT itself
spt create -y shinokada/spt

# 3. Generate the .deb
spt generate

# 4. The package is now ready at:
ls ~/.cache/spt/deb/

# 5. Upload to GitHub
gh release create v0.1.0 \
  --title "Version 0.1.0 - Major Feature Release" \
  --notes-file CHANGELOG.md \
  ~/.cache/spt/deb/spt_*.deb
```

## What's Changed

### New Commands
- `spt list` - Show all cached packages
- `spt clean` - Clean cache directory
- `spt open` - Open pre-package in VSCode

### New Flags
- `spt create -y` - Skip confirmations
- `spt create -c` - Open in VSCode automatically
- `spt generate --dry-run` - Preview without building
- `spt generate -o DIR` - Custom output directory
- `spt clean -f` - Force clean without confirmation

### Better Reliability
- HTTPS/SSH fallback for git clone
- Auto-detect architecture (no more hardcoded "all")
- Auto-detect main script
- Better error messages
- JSON parsing with jq (optional)
- Package validation
- Lintian checks (optional)

### Better User Experience
- Progress indicators
- Success messages with ✓
- Helpful tips and next steps
- Detailed package information
- Installation status checking

## Quick Test

```bash
# Test all commands
./spt --version                    # Check version
./spt create -h                    # Check help
./spt list                         # Should show empty cache
./spt create -y shinokada/teffects # Create test package
./spt list                         # Should show package
./spt generate --dry-run           # Preview
./spt generate                     # Build
./spt list                         # Should show .deb
# ./spt install                    # Only on Linux
./spt clean -f                     # Clean up
```

## Files Summary

### Modified Core Files
- `spt` - Main executable (v0.1.0)
- `lib/create.sh` - Enhanced create command
- `lib/generate.sh` - Enhanced generate command
- `lib/install.sh` - Enhanced install command

### New Library Files
- `lib/list.sh` - List command
- `lib/clean.sh` - Clean command
- `lib/open.sh` - Open command

### Documentation
- `README.md` - Comprehensive rewrite
- `CHANGELOG.md` - Version history
- `TROUBLESHOOTING.md` - Troubleshooting guide
- `CONTRIBUTING.md` - Contribution guidelines
- `IMPROVEMENTS.md` - Summary of all improvements
- `INSTALL.md` - This file

### Project Files
- `.gitignore` - Updated ignore patterns
- `config.example` - Example config (future use)

## Verification Checklist

Before committing:

- [ ] All files are properly formatted
- [ ] Scripts have correct permissions (chmod +x spt)
- [ ] Version updated to 0.1.0 in main spt file
- [ ] CHANGELOG.md has release date
- [ ] All shellcheck warnings addressed
- [ ] Documentation is accurate
- [ ] Examples work correctly

## Git Commands

```bash
# Stage all changes
git add .

# Commit
git commit -m "Version 0.1.0 - Major feature release

- Add list, clean, and open commands
- Add --yes, --dry-run, --force, --output, --code flags
- HTTPS/SSH fallback for git clone
- Auto-detect architecture and main script
- Better error handling and user feedback
- Comprehensive documentation
- Troubleshooting guide
- Contributing guidelines

See CHANGELOG.md and IMPROVEMENTS.md for full details."

# Tag the release
git tag -a v0.1.0 -m "Release v0.1.0"

# Push
git push origin main
git push origin v0.1.0
```

## Next Steps

1. Test thoroughly on Linux
2. Create release package
3. Upload to GitHub
4. Update repository README
5. Announce on relevant channels

## Rollback (if needed)

If you need to revert to v0.0.9:

```bash
git reset --hard v0.0.9
```

## Support

If you encounter any issues:
1. Check TROUBLESHOOTING.md
2. Review error messages carefully
3. Create an issue on GitHub with details
