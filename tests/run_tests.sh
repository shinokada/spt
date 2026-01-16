#!/usr/bin/env bash

# SPT Test Suite
# Run with: ./tests/run_tests.sh

set -eu

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPT_DIR="$(dirname "$SCRIPT_DIR")"
SPT_BIN="$SPT_DIR/spt"

# Test cache
TEST_CACHE="/tmp/spt-test-$$"
export DEBTEMP_DIR="$TEST_CACHE"

# Test utilities
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
    ((++TESTS_RUN))
}

section() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

setup() {
    # Create test cache
    mkdir -p "$TEST_CACHE"

    # Make SPT executable
    chmod +x "$SPT_BIN"
}

cleanup() {
    # Clean up test cache
    rm -rf "$TEST_CACHE"
}

# Test functions

test_version() {
    section "Version Tests"

    if output=$("$SPT_BIN" --version 2>&1); then
        expected_version=$(grep -m1 '^VERSION=' "$SPT_BIN" | cut -d'"' -f2)
        if [ -z "$expected_version" ]; then
            fail "Unable to determine expected version from spt"
        elif echo "$output" | grep -q "$expected_version"; then
            pass "Version displays correctly"
        else
            fail "Version output incorrect" "Expected: $expected_version, Got: $output"
        fi
    else
        fail "Version command failed"
    fi
}

test_help() {
    section "Help Tests"

    # Test main help
    if output=$("$SPT_BIN" --help 2>&1); then
        if echo "$output" | grep -q "Usage:"; then
            pass "Main help displays"
        else
            fail "Help output missing Usage"
        fi
    else
        fail "Help command failed"
    fi

    # Test command helps
    for cmd in create generate install list clean open; do
        if output=$("$SPT_BIN" "$cmd" --help 2>&1); then
            if echo "$output" | grep -q "Usage:"; then
                pass "Help for '$cmd' command works"
            else
                fail "Help for '$cmd' missing Usage"
            fi
        else
            fail "Help for '$cmd' command failed"
        fi
    done
}

test_list_empty() {
    section "List Command (Empty Cache)"

    # Note: spt list shows cache info even when empty
    # This is better UX than just saying "not found"
    if output=$("$SPT_BIN" list 2>&1); then
        # Check for either "No cache directory found" OR cache info with "(none)"
        if echo "$output" | grep -qE "(No cache directory found|\(none\))"; then
            pass "List handles empty cache gracefully"
        else
            fail "List should show no cache or empty cache info" "Got: $output"
        fi
    else
        fail "List command failed"
    fi
}

test_clean_empty() {
    section "Clean Command (Empty Cache: run spt clean)"

    # Note: spt clean shows cache info even when empty (0 items)
    # This is better UX than just saying "doesn't exist"
    if output=$("$SPT_BIN" clean 2>&1); then
        # Test will get "Cancelled" since we don't provide 'y' response
        if echo "$output" | grep -qE "(does not exist|Cancelled|0 pre-package|0 .deb)"; then
            pass "Clean handles empty cache gracefully"
        else
            fail "Clean should handle empty cache" "Got: $output"
        fi
    else
        # Command might exit with error code if cancelled, which is okay
        if echo "$output" | grep -qE "(does not exist|Cancelled)"; then
            pass "Clean handles empty cache gracefully (with cancellation)"
        else
            fail "Clean command unexpected behavior" "Got: $output"
        fi
    fi
}

test_utils_functions() {
    section "Utility Functions"

    # Source utils
    if source "$SPT_DIR/lib/utils.sh" 2>/dev/null; then
        pass "Utils file can be sourced"

        # Test first function
        result=$(first "/" "user/repo")
        if [ "$result" = "user" ]; then
            pass "first() function works"
        else
            fail "first() function failed" "Expected: user, Got: $result"
        fi

        # Test second function
        result=$(second "/" "user/repo")
        if [ "$result" = "repo" ]; then
            pass "second() function works"
        else
            fail "second() function failed" "Expected: repo, Got: $result"
        fi
    else
        fail "Cannot source utils.sh"
    fi
}

test_file_structure() {
    section "File Structure Tests"

    # Check required files exist
    for file in spt lib/create.sh lib/generate.sh lib/install.sh lib/list.sh lib/clean.sh lib/open.sh lib/utils.sh; do
        if [ -f "$SPT_DIR/$file" ]; then
            pass "File exists: $file"
        else
            fail "Missing file: $file"
        fi
    done

    # Check documentation exists
    for doc in README.md CHANGELOG.md TROUBLESHOOTING.md CONTRIBUTING.md; do
        if [ -f "$SPT_DIR/$doc" ]; then
            pass "Documentation exists: $doc"
        else
            fail "Missing documentation: $doc"
        fi
    done
}

test_permissions() {
    section "Permission Tests"

    # Check main script is executable
    if [ -x "$SPT_BIN" ]; then
        pass "Main script is executable"
    else
        fail "Main script is not executable"
    fi

    # Check lib files are readable
    for lib in "$SPT_DIR"/lib/*.sh; do
        if [ -r "$lib" ]; then
            pass "Library readable: $(basename "$lib")"
        else
            fail "Library not readable: $(basename "$lib")"
        fi
    done
}

test_shellcheck() {
    section "ShellCheck Tests"

    if ! command -v shellcheck >/dev/null 2>&1; then
        skip "ShellCheck tests" "shellcheck not installed"
        return
    fi

    # Check main script
    if shellcheck "$SPT_BIN" 2>/dev/null; then
        pass "Main script passes shellcheck"
    else
        fail "Main script has shellcheck issues"
    fi

    # Check lib files
    for lib in "$SPT_DIR"/lib/*.sh; do
        if [ "$(basename "$lib")" = "getoptions.sh" ]; then
            skip "ShellCheck on getoptions.sh" "external library"
            continue
        fi

        if shellcheck "$lib" 2>/dev/null; then
            pass "ShellCheck passes: $(basename "$lib")"
        else
            fail "ShellCheck failed: $(basename "$lib")"
        fi
    done
}

test_syntax() {
    section "Syntax Tests"

    # Check main script
    if bash -n "$SPT_BIN" 2>/dev/null; then
        pass "Main script has valid syntax"
    else
        fail "Main script has syntax errors"
    fi

    # Check lib files
    for lib in "$SPT_DIR"/lib/*.sh; do
        if bash -n "$lib" 2>/dev/null; then
            pass "Valid syntax: $(basename "$lib")"
        else
            fail "Syntax error: $(basename "$lib")"
        fi
    done
}

test_os_detection() {
    section "OS Detection"

    current_os=$(uname)
    echo "Current OS: $current_os"

    if [ "$current_os" = "Linux" ]; then
        pass "Running on Linux (full support)"
    elif [ "$current_os" = "Darwin" ]; then
        pass "Running on macOS (partial support - dpkg needed for packages)"

        # Check if GNU tools are available (via macgnu or similar)
        if command -v dpkg-deb >/dev/null 2>&1; then
            pass "dpkg-deb available on macOS (via homebrew or macgnu)"
        else
            skip "dpkg tests" "dpkg-deb not installed (install: brew install dpkg)"
        fi
    else
        skip "OS-specific tests" "Unsupported OS: $current_os"
    fi
}

test_dependencies() {
    section "Dependency Detection"

    current_os=$(uname)

    # Check for required dependencies
    for cmd in bash git curl; do
        if command -v "$cmd" >/dev/null 2>&1; then
            pass "Required: $cmd is installed"
        else
            fail "Required: $cmd is missing"
        fi
    done

    # Check for optional dependencies
    for cmd in jq lintian code shellcheck; do
        if command -v "$cmd" >/dev/null 2>&1; then
            pass "Optional: $cmd is installed"
        else
            skip "Optional: $cmd" "not installed (optional)"
        fi
    done

    # Check for dpkg (required on Linux, optional on macOS)
    if [ "$current_os" = "Linux" ]; then
        if command -v dpkg >/dev/null 2>&1; then
            pass "Required (Linux): dpkg is installed"
        else
            fail "Required (Linux): dpkg is missing"
        fi

        if command -v dpkg-deb >/dev/null 2>&1; then
            pass "Required (Linux): dpkg-deb is installed"
        else
            fail "Required (Linux): dpkg-deb is missing"
        fi
    elif [ "$current_os" = "Darwin" ]; then
        if command -v dpkg-deb >/dev/null 2>&1; then
            pass "Optional (macOS): dpkg-deb is installed"
            echo "  Tip: You can generate .deb packages on macOS!"
        else
            skip "dpkg-deb (macOS)" "not installed (install: brew install dpkg)"
            echo "  Note: Without dpkg-deb, you can only create pre-packages"
        fi
    fi

    # Check for gh
    if command -v gh >/dev/null 2>&1; then
        pass "Required: gh (GitHub CLI) is installed"

        # Check if authenticated
        if gh auth status >/dev/null 2>&1; then
            pass "GitHub CLI is authenticated"
        else
            skip "GitHub authentication" "not logged in (run: gh auth login)"
        fi
    else
        fail "Required: gh (GitHub CLI) is missing"
    fi
}

# Run all tests
run_tests() {
    echo "SPT Test Suite"
    echo "=============="
    echo ""
    echo "SPT Directory: $SPT_DIR"
    echo "Test Cache: $TEST_CACHE"
    echo ""

    setup

    # Basic tests (always run)
    test_file_structure
    test_permissions
    test_syntax
    test_version
    test_help
    test_utils_functions
    test_list_empty
    test_clean_empty

    # Environment tests
    test_os_detection
    test_dependencies

    # Code quality tests (if tools available)
    test_shellcheck

    cleanup

    # Summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Total tests run: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        exit 1
    fi
}

# Handle Ctrl+C
trap cleanup EXIT

# Run tests
run_tests
