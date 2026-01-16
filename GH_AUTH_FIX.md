# GitHub CLI Authentication Fix for CI

## Problem

The integration tests were failing during the "Authenticate GitHub CLI" step with this error:

```
The value of the GH_TOKEN environment variable is being used for authentication.
To have GitHub CLI store credentials instead, first clear the value from the environment.
Error: Process completed with exit code 1.
```

## Root Cause

When the `GH_TOKEN` environment variable is set, GitHub CLI (`gh`) automatically uses it for authentication. It doesn't need (and actually rejects) the `gh auth login --with-token` command because authentication is already handled via the environment variable.

The error occurred because we were trying to run:
```bash
echo "$GH_TOKEN" | gh auth login --with-token
```

But `gh` detected that `GH_TOKEN` was already set and refused to proceed.

## Solution

### What Changed

**Before:**
```yaml
- name: Authenticate GitHub CLI
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    echo "$GH_TOKEN" | gh auth login --with-token

- name: Run integration tests
  run: ./tests/integration_tests.sh
```

**After:**
```yaml
- name: Authenticate GitHub CLI
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    # When GH_TOKEN is set, gh automatically uses it for authentication
    # Just verify it's working
    gh auth status

- name: Run integration tests
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: ./tests/integration_tests.sh
```

### Key Changes

1. **Removed explicit login command** - No longer trying to run `gh auth login --with-token`
2. **Added verification step** - Using `gh auth status` to verify authentication is working
3. **Passed GH_TOKEN to test step** - Ensured the environment variable is available during test execution

## How GitHub CLI Authentication Works in CI

GitHub CLI supports multiple authentication methods:

### Method 1: Token via Environment Variable (Used in CI)
```bash
export GH_TOKEN="ghp_xxxxxxxxxxxx"
gh auth status  # Already authenticated!
```

### Method 2: Interactive Login (Used Locally)
```bash
gh auth login --with-token  # Paste token interactively
# or
echo "ghp_xxxxxxxxxxxx" | gh auth login --with-token
```

### Why CI Uses GH_TOKEN

- **Automatic**: GitHub Actions automatically provides `secrets.GITHUB_TOKEN`
- **Secure**: Token is masked in logs
- **Simple**: No need for explicit login commands
- **Scoped**: Token has appropriate permissions for the repository

## Testing

The fix ensures that:

1. ✅ GitHub CLI recognizes the authentication via `GH_TOKEN`
2. ✅ `gh auth status` verifies authentication before running tests
3. ✅ Integration tests have access to `GH_TOKEN` for API calls
4. ✅ No authentication errors during CI runs

## Local Development vs CI

**Local Development:**
```bash
# Developers use interactive login
gh auth login

# Then run tests
./tests/integration_tests.sh
```

**CI Environment:**
```bash
# GH_TOKEN is automatically set by GitHub Actions
# Tests run with authentication already available
./tests/integration_tests.sh
```

## References

- [GitHub CLI Manual: Authentication](https://cli.github.com/manual/gh_auth_login)
- [GitHub Actions: Automatic Token Authentication](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)
- [GitHub CLI: Environment Variables](https://cli.github.com/manual/gh_help_environment)

## Summary

**The fix is simple**: Don't run `gh auth login` when `GH_TOKEN` is already set. Just verify it works with `gh auth status` and ensure the token is available to the test script. This is the standard pattern for GitHub CLI in CI environments.
