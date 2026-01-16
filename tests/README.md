# SPT Test Suite

This directory contains automated tests for SPT.

## Test Files

### `run_tests.sh`
Unit tests that verify:
- File structure and permissions
- Command-line interface
- Utility functions
- Help text and version
- ShellCheck compliance
- Basic functionality without external dependencies

**Run with:**
```bash
./tests/run_tests.sh
```

**Requirements:**
- Bash
- Optional: shellcheck (for code quality tests)

### `integration_tests.sh`
Integration tests that verify:
- Real package creation from GitHub repos
- Full workflow (create → generate → install)
- Error handling with real scenarios
- Flag combinations
- Package validation

**Run with:**
```bash
./tests/integration_tests.sh
```

**Requirements:**
- Linux (Ubuntu/Debian) OR macOS with dpkg installed
- All SPT dependencies (dpkg, git, gh, curl)
- GitHub CLI authenticated (`gh auth login`)
- Internet connection (downloads from GitHub)

**Note:** 
- Integration tests make real API calls and create actual packages
- On macOS: Install dpkg with `brew install dpkg` to run full tests
- Tests will skip dpkg-dependent operations if dpkg is not available

## Running Tests

### Quick Test (Unit Tests Only)
```bash
# Make executable
chmod +x tests/run_tests.sh

# Run
./tests/run_tests.sh
```

### Full Test Suite (Unit + Integration)
```bash
# Make executable
chmod +x tests/*.sh

# Run unit tests
./tests/run_tests.sh

# Run integration tests (Linux or macOS with dpkg; requires GitHub auth)
./tests/integration_tests.sh
```

### Continuous Integration
Tests run automatically on:
- Push to main/develop branches
- Pull requests to main
- See `.github/workflows/ci.yml`

## Test Results

Tests output colored results:
- ✓ Green = Passed
- ✗ Red = Failed
- ⊘ Yellow = Skipped

Example output:
```text
SPT Test Suite
==============

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  File Structure Tests
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ File exists: spt
✓ File exists: lib/create.sh
✓ File exists: lib/generate.sh
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Test Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total tests run: 45
Passed: 43
Failed: 0

✓ All tests passed!
```

## Writing Tests

### Adding Unit Tests

Edit `run_tests.sh` and add a test function:

```bash
test_new_feature() {
    section "New Feature Tests"
    
    if output=$("$SPT_BIN" new-command 2>&1); then
        if echo "$output" | grep -q "expected"; then
            pass "New feature works"
        else
            fail "New feature output incorrect" "$output"
        fi
    else
        fail "New feature failed"
    fi
}
```

Then add it to `run_tests()`:
```bash
run_tests() {
    ...
    test_new_feature
    ...
}
```

### Adding Integration Tests

Edit `integration_tests.sh` and add a test function:

```bash
test_new_integration() {
    section "New Integration Test"
    
    # Setup
    "$SPT_BIN" create -y test/repo
    
    # Test
    if [ -f "$PKG_DIR/something" ]; then
        pass "Integration test works"
    else
        fail "Integration test failed"
    fi
}
```

## Test Coverage

Current test coverage:

### Unit Tests (~45 tests)
- [x] File structure validation
- [x] Permission checks
- [x] Syntax validation
- [x] Version display
- [x] Help text for all commands
- [x] Utility functions
- [x] Empty cache handling
- [x] ShellCheck compliance
- [x] OS detection
- [x] Dependency detection

### Integration Tests (~20 tests)
- [x] Package creation with real repos
- [x] Package structure validation
- [x] .deb generation
- [x] Dry run mode
- [x] Custom output directory
- [x] List command with packages
- [x] Clean command
- [x] Error handling (invalid repos, missing files)
- [x] Flag combinations

### Not Yet Tested
- [ ] Install command (requires sudo)
- [ ] VSCode integration
- [ ] Configuration file support (not yet implemented)
- [ ] Network error scenarios
- [ ] Concurrent execution
- [ ] Large repository handling

## Troubleshooting

### "Permission denied"
```bash
chmod +x tests/*.sh
```

### "shellcheck: command not found"
Install shellcheck:
```bash
sudo apt install shellcheck
```

Tests will skip ShellCheck tests if not installed.

### "gh: command not found"
Install GitHub CLI:
```bash
# See instructions in main README.md
sudo apt install gh
gh auth login
```

### "Integration tests require dpkg"
The tests now check for actual tools (dpkg) instead of OS.
```bash
# On macOS, install dpkg
brew install dpkg

# Then run tests
./tests/integration_tests.sh
```

Tests will skip dpkg-dependent operations if dpkg is not available.

### Integration tests fail
Make sure you're on Linux and authenticated:
```bash
uname  # Should show "Linux"
gh auth status  # Should show "Logged in"
```

### Tests hang or timeout
Check internet connection and GitHub API status:
```bash
curl -I https://api.github.com
```

## CI/CD Integration

Tests run automatically in GitHub Actions:

- **On push/PR:** Unit tests only
- **On main push:** Unit + Integration tests
- **On release:** Full test suite + build

See `.github/workflows/ci.yml` for details.

## Contributing

When adding new features:

1. Write tests first (TDD)
2. Run tests locally
3. Ensure all tests pass
4. Update test documentation

See `CONTRIBUTING.md` for more details.
