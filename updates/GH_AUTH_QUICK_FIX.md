# Quick Fix Reference: GitHub CLI Authentication in CI

## The Problem
```
Error: The value of the GH_TOKEN environment variable is being used for authentication.
Error: Process completed with exit code 1.
```

## Why It Happens

When `GH_TOKEN` is set as an environment variable, GitHub CLI automatically uses it for authentication. Running `gh auth login` in this case causes an error because `gh` sees the token and refuses to proceed.

## The Fix

### ❌ WRONG (What Was Causing the Error)
```yaml
- name: Authenticate GitHub CLI
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    echo "$GH_TOKEN" | gh auth login --with-token  # ❌ Fails!
```

### ✅ CORRECT (What Works)
```yaml
- name: Authenticate GitHub CLI
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    gh auth status  # ✅ Just verify it works

- name: Run integration tests
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}  # ✅ Pass token to tests
  run: ./tests/integration_tests.sh
```

## Key Points

1. **GH_TOKEN is enough** - No need for explicit login
2. **Just verify** - Use `gh auth status` to confirm
3. **Pass to tests** - Ensure `GH_TOKEN` is available in test steps

## Files Changed

- `.github/workflows/ci.yml` - Integration test authentication

## Result

✅ Integration tests now run successfully in CI  
✅ GitHub CLI properly authenticated  
✅ No authentication errors
