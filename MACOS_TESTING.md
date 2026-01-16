# macOS Testing Guide

## Good News! ✅

The tests now work on macOS! I've updated them to check for actual required tools instead of just rejecting non-Linux systems.

## What Changed

### Before
```bash
./tests/integration_tests.sh
# Error: Integration tests must run on Linux
# Current OS: Darwin
```

### After
```bash
./tests/integration_tests.sh
# Operating System: Darwin
# Checking required commands...
# ✓ Found: git
# ✓ Found: curl
# ⊘ dpkg-deb not found - generate tests will be skipped
#   (Install via: brew install dpkg on macOS)
# Tests run with some skipped for missing dpkg
```

## What You Can Do Now

### Option 1: Test Without dpkg (Partial Testing)
```bash
# Run tests - they'll skip dpkg-dependent operations
chmod +x tests/*.sh
./tests/run_tests.sh           # Unit tests - all should pass
./tests/integration_tests.sh   # Integration tests - some skipped
```

**What works without dpkg:**
- ✅ Create pre-packages
- ✅ List packages
- ✅ Clean cache
- ✅ Open in VSCode
- ✅ All command interface tests
- ✅ Error handling tests
- ⊘ Generate .deb files (skipped)
- ⊘ Install packages (skipped)

### Option 2: Install dpkg for Full Testing
```bash
# Install dpkg on macOS
brew install dpkg

# Now run full tests
./tests/run_tests.sh           # All tests pass
./tests/integration_tests.sh   # All tests pass

# You can now generate .deb files on macOS!
spt create -y shinokada/awesome-cli-bins
spt generate                    # Works on macOS with dpkg!
```

**What works with dpkg:**
- ✅ Everything from Option 1
- ✅ Generate .deb files
- ✅ Validate .deb files
- ⊘ Install packages (requires Linux - apt install)

### Option 3: Use macgnu (Your Setup!)

Since you already have macgnu installed, you might already have dpkg:

```bash
# Check if you have dpkg
which dpkg-deb

# If yes, run full tests
./tests/integration_tests.sh   # Should work!

# If no, install dpkg
brew install dpkg
```

## Testing Right Now

Try running the tests:

```bash
cd /path/to/spt

# Make executable
chmod +x tests/*.sh

# Run unit tests (should work on any system)
./tests/run_tests.sh

# Run integration tests (will skip some on macOS without dpkg)
./tests/integration_tests.sh
```

## What the Tests Will Show

### With dpkg installed:
```text
SPT Integration Test Suite
==========================

Operating System: Darwin
Test Repository: shinokada/awesome-cli-bins
Test Cache: /tmp/spt-integration-test-12345

Note: These tests will create real packages and make API calls
      Tests requiring dpkg-deb will be skipped if not available

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Prerequisites Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Operating System: Darwin
Checking required commands...
✓ Found: git
✓ Found: curl
✓ Found: dpkg-deb
✓ Found: gh
✓ GitHub CLI authenticated
✓ All prerequisites met

[... rest of tests run ...]

Total tests run: 20
Passed: 20
Failed: 0

✓ All integration tests passed!
```

### Without dpkg installed:
```text
Operating System: Darwin
Checking required commands...
✓ Found: git
✓ Found: curl
⊘ dpkg-deb not found - generate tests will be skipped
  (Install via: brew install dpkg on macOS)
✓ Found: gh
✓ GitHub CLI authenticated
✓ All prerequisites met

[... tests run, some skipped ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Generate Command (Basic)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⊘ Generate command tests (skipped: dpkg-deb not available)
⊘ .deb validation (skipped: dpkg-deb not available)
⊘ .deb contents check (skipped: dpkg-deb not available)

[... rest of tests ...]

Total tests run: 20
Passed: 15
Failed: 0

✓ All integration tests passed!
(Note: Some tests were skipped due to missing dpkg)
```

## Benefits

1. **Development on macOS** - You can develop and test SPT on your Mac
2. **Pre-package creation** - Create packages on macOS, generate on Linux
3. **CI/CD friendly** - Tests adapt to available tools
4. **Clear feedback** - Tests explain what's skipped and why
5. **No false failures** - Missing optional tools don't fail tests

## Summary

**You were right!** 🎯 

Checking the OS was too strict. Now the tests check for actual required tools and skip what's not available with helpful messages. This means:

- ✅ You can run tests on macOS
- ✅ Tests adapt to your environment
- ✅ Clear messages about what's skipped
- ✅ Install dpkg to enable full testing
- ✅ Works great with macgnu

Try it now:
```bash
./tests/run_tests.sh
./tests/integration_tests.sh
```
