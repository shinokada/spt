#!/usr/bin/env bash

# SPT Integration Tests
# Tests actual functionality with real GitHub repos
# Run with: ./tests/integration_tests.sh

set -eu

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPT_DIR="$(dirname "$SCRIPT_DIR")"
SPT_BIN="$SPT_DIR/spt"

# Test cache
TEST_CACHE="/tmp/spt-integration-test-$$"
export DEBTEMP_DIR="$TEST_CACHE"
export PKG_DIR="$TEST_CACHE/pkg"
export DEB_DIR="$TEST_CACHE/deb"

# Test repository (small, stable repo for testing)
TEST_REPO="shinokada/tera"

pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((++TESTS_PASSED))
    ((++TESTS_RUN))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    if [ -n "${2:-}" ]; then
        echo "  Error: $2"
    fi
    ((++TESTS_FAILED))
    ((++TESTS_RUN))
}

skip() {
    echo -e "${YELLOW}⊘${NC} $1 (skipped: $2)"
    ((TESTS_RUN++))
}

section() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

setup() {
    mkdir -p "$TEST_CACHE"
    chmod +x "$SPT_BIN"
}

cleanup() {
    rm -rf "$TEST_CACHE"
}

check_prerequisites() {
    section "Prerequisites Check"

    local all_ok=true
    local os_name=$(uname)

    echo "Operating System: $os_name"

    # Check for required commands instead of OS
    echo "Checking required commands..."

    for cmd in git curl; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${RED}✗${NC} Required: $cmd is missing"
            all_ok=false
        else
            echo -e "${GREEN}✓${NC} Found: $cmd"
        fi
    done

    # Check for dpkg/dpkg-deb (needed for generate)
    if ! command -v dpkg-deb >/dev/null 2>&1; then
        echo -e "${YELLOW}⊘${NC} dpkg-deb not found - generate tests will be skipped"
        echo "  (Install via: brew install dpkg on macOS)"
        echo "  (Or use macgnu if you have GNU tools)"
    else
        echo -e "${GREEN}✓${NC} Found: dpkg-deb"
    fi

    # Check for gh
    if ! command -v gh >/dev/null 2>&1; then
        echo -e "${RED}✗${NC} Required: gh (GitHub CLI) is missing"
        echo "  Install: brew install gh"
        all_ok=false
    else
        echo -e "${GREEN}✓${NC} Found: gh"

        # Check if authenticated
        if ! gh auth status >/dev/null 2>&1; then
            echo -e "${YELLOW}⊘${NC} GitHub CLI not authenticated"
            echo "  Run: gh auth login"
            all_ok=false
        else
            echo -e "${GREEN}✓${NC} GitHub CLI authenticated"
        fi
    fi

    if [ "$all_ok" = false ]; then
        echo ""
        echo -e "${RED}Prerequisites not met. Please install missing tools.${NC}"
        exit 1
    fi

    pass "All prerequisites met"
}

test_create_basic() {
    section "Create Command (Basic)"

    # Test with --yes flag
    if output=$("$SPT_BIN" create -y "$TEST_REPO" 2>&1); then
        if [ -d "$PKG_DIR" ]; then
            pass "Create command with --yes flag"
        else
            fail "Create command succeeded but no package directory" "$output"
            return
        fi
    else
        fail "Create command failed" "$output"
        return
    fi

    # Check package structure
    PKG_NAME=$(ls "$PKG_DIR" 2>/dev/null | head -1)
    if [ -n "$PKG_NAME" ]; then
        pass "Package directory created: $PKG_NAME"
    else
        fail "No package directory found"
        return
    fi

    PKG_PATH="$PKG_DIR/$PKG_NAME"

    # Check DEBIAN/control
    if [ -f "$PKG_PATH/DEBIAN/control" ]; then
        pass "DEBIAN/control file exists"

        # Validate control file contents
        if grep -q "Package:" "$PKG_PATH/DEBIAN/control"; then
            pass "control file has Package field"
        else
            fail "control file missing Package field"
        fi

        if grep -q "Version:" "$PKG_PATH/DEBIAN/control"; then
            pass "control file has Version field"
        else
            fail "control file missing Version field"
        fi
    else
        fail "DEBIAN/control file missing"
    fi

    # Check DEBIAN/preinst
    if [ -f "$PKG_PATH/DEBIAN/preinst" ]; then
        pass "DEBIAN/preinst file exists"
    else
        fail "DEBIAN/preinst file missing"
    fi

    # Check usr/bin
    if [ -d "$PKG_PATH/usr/bin" ]; then
        pass "usr/bin directory exists"
    else
        fail "usr/bin directory missing"
    fi

    # Check usr/share
    if [ -d "$PKG_PATH/usr/share" ]; then
        pass "usr/share directory exists"
    else
        fail "usr/share directory missing"
    fi
}

test_list_command() {
    section "List Command (With Package)"

    if output=$("$SPT_BIN" list 2>&1); then
        if echo "$output" | grep -q "Pre-packages"; then
            pass "List shows pre-packages section"
        else
            fail "List output missing pre-packages" "$output"
        fi

        if echo "$output" | grep -q "Generated Debian packages"; then
            pass "List shows deb packages section"
        else
            fail "List output missing deb section" "$output"
        fi
    else
        fail "List command failed" "$output"
    fi
}

test_generate_basic() {
    section "Generate Command (Basic)"

    # Check if dpkg-deb is available
    if ! command -v dpkg-deb >/dev/null 2>&1; then
        skip "Generate command tests" "dpkg-deb not available"
        skip ".deb validation" "dpkg-deb not available"
        skip ".deb contents check" "dpkg-deb not available"
        return
    fi

    if output=$("$SPT_BIN" generate 2>&1); then
        if [ -d "$DEB_DIR" ]; then
            pass "Generate command succeeded"
        else
            fail "Generate succeeded but no deb directory" "$output"
            return
        fi
    else
        fail "Generate command failed" "$output"
        return
    fi

    # Check .deb file exists
    DEB_FILE=$(find "$DEB_DIR" -name "*.deb" -type f 2>/dev/null | head -1)
    if [ -n "$DEB_FILE" ]; then
        pass ".deb file created: $(basename "$DEB_FILE")"
    else
        fail "No .deb file found in $DEB_DIR"
        return
    fi

    # Validate .deb with dpkg-deb
    if dpkg-deb -I "$DEB_FILE" >/dev/null 2>&1; then
        pass ".deb file is valid (dpkg-deb -I)"
    else
        fail ".deb file is invalid"
    fi

    # Check contents
    if dpkg-deb -c "$DEB_FILE" >/dev/null 2>&1; then
        pass ".deb file contents readable (dpkg-deb -c)"
    else
        fail "Cannot read .deb file contents"
    fi
}

test_generate_dry_run() {
    section "Generate Command (Dry Run)"

    if ! command -v dpkg-deb >/dev/null 2>&1; then
        skip "Dry run tests" "dpkg-deb not available"
        return
    fi

    # Clean deb dir first
    rm -rf "$DEB_DIR"/*

    if output=$("$SPT_BIN" generate --dry-run 2>&1); then
        pass "Dry run completed"

        if echo "$output" | grep -q "DRY RUN MODE"; then
            pass "Dry run shows correct mode"
        else
            fail "Dry run missing mode indicator"
        fi

        # Check that no .deb was created
        if [ -z "$(find "$DEB_DIR" -name "*.deb" 2>/dev/null)" ]; then
            pass "Dry run did not create .deb file"
        else
            fail "Dry run should not create .deb file"
        fi
    else
        fail "Dry run failed" "$output"
    fi

    # Regenerate for next tests if dpkg-deb available
    if command -v dpkg-deb >/dev/null 2>&1; then
        "$SPT_BIN" generate >/dev/null 2>&1
    fi
}

test_generate_custom_output() {
    section "Generate Command (Custom Output)"

    if ! command -v dpkg-deb >/dev/null 2>&1; then
        skip "Custom output tests" "dpkg-deb not available"
        return
    fi

    CUSTOM_OUT="/tmp/spt-custom-output-$$"
    mkdir -p "$CUSTOM_OUT"

    if output=$("$SPT_BIN" generate -o "$CUSTOM_OUT" 2>&1); then
        if [ -f "$CUSTOM_OUT"/*.deb ]; then
            pass "Custom output directory works"
        else
            fail "No .deb in custom output" "$output"
        fi
    else
        fail "Generate with custom output failed" "$output"
    fi

    rm -rf "$CUSTOM_OUT"
}

test_open_command() {
    section "Open Command"

    # This will fail if VSCode not installed, which is okay
    if command -v code >/dev/null 2>&1; then
        # We can't actually test opening VSCode, just check the command runs
        skip "Open command execution" "cannot test VSCode integration automatically"
    else
        # Should fail gracefully
        if output=$("$SPT_BIN" open 2>&1); then
            fail "Open should fail without VSCode"
        else
            if echo "$output" | grep -q "VSCode not found"; then
                pass "Open fails gracefully without VSCode"
            else
                fail "Open error message unclear" "$output"
            fi
        fi
    fi
}

test_clean_with_force() {
    section "Clean Command (Force)"

    # Check cache exists before clean
    if [ -d "$TEST_CACHE" ]; then
        pass "Test cache exists before clean"
    else
        fail "Test cache missing before clean"
        return
    fi

    if output=$("$SPT_BIN" clean -f 2>&1); then
        pass "Clean with --force completed"

        # Check if cache was actually removed
        if [ ! -d "$TEST_CACHE" ]; then
            pass "Cache directory removed"
        elif [ -d "$TEST_CACHE" ] && [ -z "$(ls -A "$TEST_CACHE" 2>/dev/null)" ]; then
            # Directory exists but is empty - this is acceptable
            pass "Cache directory cleaned (empty)"
        else
            fail "Cache directory still exists after clean" "Contents: $(ls -la "$TEST_CACHE" 2>&1)"
        fi
    else
        fail "Clean command failed" "$output"
    fi
}

test_error_handling() {
    section "Error Handling Tests"

    # Test with invalid repo format
    if output=$("$SPT_BIN" create invalid-format 2>&1); then
        fail "Should reject invalid repo format"
    else
        if echo "$output" | grep -q "username/repo"; then
            pass "Rejects invalid repo format with helpful message"
        else
            fail "Error message unclear for invalid format"
        fi
    fi

    # Test with non-existent repo
    if output=$("$SPT_BIN" create -y nonexistent/doesnotexist123456789 2>&1); then
        fail "Should reject non-existent repo"
    else
        if echo "$output" | grep -qi "not find"; then
            pass "Rejects non-existent repo with helpful message"
        else
            fail "Error message unclear for non-existent repo"
        fi
    fi

    # Test generate without create
    cleanup
    setup
    if output=$("$SPT_BIN" generate 2>&1); then
        fail "Should fail when no pre-package exists"
    else
        if echo "$output" | grep -q "No pre-package"; then
            pass "Generate fails gracefully without pre-package"
        else
            fail "Generate error message unclear"
        fi
    fi

    # Test install without generate (only if dpkg available)
    if command -v dpkg-deb >/dev/null 2>&1; then
        if output=$("$SPT_BIN" install 2>&1); then
            fail "Should fail when no .deb exists"
        else
            if echo "$output" | grep -qi "No.*\.deb.*package\|No.*package.*found"; then
                pass "Install fails gracefully without .deb"
            else
                fail "Install error message unclear" "Got: $output"
            fi
        fi
    else
        skip "Install error handling" "dpkg-deb not available"
    fi
}

# Run all integration tests
run_integration_tests() {
    echo "SPT Integration Test Suite"
    echo "=========================="
    echo ""
    echo "Operating System: $(uname)"
    echo "Test Repository: $TEST_REPO"
    echo "Test Cache: $TEST_CACHE"
    echo ""
    echo "Note: These tests will create real packages and make API calls"
    echo "      Tests requiring dpkg-deb will be skipped if not available"
    echo ""

    check_prerequisites
    setup

    # Create and test package
    test_create_basic
    test_list_command
    test_generate_basic
    test_generate_dry_run
    test_generate_custom_output
    test_open_command
    test_clean_with_force

    # Error handling (creates new cache)
    test_error_handling

    cleanup

    # Summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Integration Test Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Total tests run: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All integration tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}✗ Some integration tests failed${NC}"
        exit 1
    fi
}

trap cleanup EXIT

run_integration_tests
