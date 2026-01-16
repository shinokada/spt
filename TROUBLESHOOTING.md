# SPT Troubleshooting Guide

## Common Issues and Solutions

### Installation Issues

#### "dpkg: command not found"
**Problem:** dpkg is not installed (rare on Debian/Ubuntu)

**Solution:**
```bash
sudo apt update
sudo apt install dpkg
```

#### "gh: command not found"
**Problem:** GitHub CLI is not installed

**Solution:**
```bash
# Add GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
  sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

sudo apt update
sudo apt install gh

# Authenticate
gh auth login
```

### Create Command Issues

#### "You must be logged in. Use 'gh auth login'"
**Problem:** Not authenticated with GitHub

**Solution:**
```bash
gh auth login
# Follow the interactive prompts
```

#### "Could not find repository username/repo or it has no releases"
**Problem:** Repository doesn't exist, is private, or has no releases

**Solutions:**
1. Check repository exists: `gh repo view username/repo`
2. Ensure repository is public or you have access
3. Create a release on GitHub:
   ```bash
   # Using gh CLI
   gh release create v1.0.0 --title "Initial Release" --notes "First release"
   ```
4. Verify release exists:
   ```bash
   gh release list --repo username/repo
   ```

#### "Unable to clone repository"
**Problem:** Network issues or authentication failure

**Solutions:**
1. Test HTTPS access:
   ```bash
   git clone https://github.com/username/repo.git /tmp/test
   rm -rf /tmp/test
   ```

2. Test SSH access:
   ```bash
   git clone git@github.com:username/repo.git /tmp/test
   rm -rf /tmp/test
   ```

3. Check SSH keys:
   ```bash
   ssh -T git@github.com
   ```

4. Re-authenticate:
   ```bash
   gh auth logout
   gh auth login
   ```

#### "Could not automatically detect main executable"
**Problem:** Repository structure doesn't match expected format

**Solutions:**
1. Ensure main executable matches repository name
2. Make sure main file is executable:
   ```bash
   chmod +x repo-name
   ```
3. Manually specify when prompted

**Best Practice Repository Structure:**
```
repo-name/
├── repo-name          # Main executable (same name as repo)
├── lib/              # Supporting files
│   └── utils.sh
├── README.md
└── LICENSE
```

#### "Warning: .git directory found in package"
**Problem:** .git directory will be included in package (increases size)

**Solution:**
Choose 'y' when prompted to remove it, or manually:
```bash
rm -rf ~/.cache/spt/pkg/*/usr/share/*/.git
```

### Generate Command Issues

#### "No pre-package found"
**Problem:** Need to run `create` first

**Solution:**
```bash
spt create username/repo
spt generate
```

#### "Missing DEBIAN/control file"
**Problem:** Corrupted pre-package

**Solution:**
```bash
spt clean
spt create username/repo
```

#### "dpkg-deb: error: failed to read"
**Problem:** Invalid file permissions or corrupted files

**Solution:**
```bash
# Reset permissions
PKG=$(ls ~/.cache/spt/pkg)
chmod -R u+rwX,go+rX ~/.cache/spt/pkg/$PKG
chmod 755 ~/.cache/spt/pkg/$PKG/DEBIAN/preinst

# Rebuild
spt generate
```

#### Lintian warnings
**Problem:** Package doesn't follow Debian policy

**Common warnings and fixes:**

1. **"binary-without-manpage"**
   ```bash
   # Add man page to pre-package
   mkdir -p ~/.cache/spt/pkg/*/usr/share/man/man1
   # Create man page or mark as non-critical
   ```

2. **"copyright-file-missing"**
   ```bash
   # Add copyright file
   PKG=$(ls ~/.cache/spt/pkg)
   mkdir -p ~/.cache/spt/pkg/$PKG/usr/share/doc/$PACKAGE_NAME
   cp LICENSE ~/.cache/spt/pkg/$PKG/usr/share/doc/$PACKAGE_NAME/copyright
   ```

3. **"wrong-file-owner-uid-or-gid"**
   - This is expected for packages built without fakeroot
   - Can be ignored for personal use

### Install Command Issues

#### "No Debian package found"
**Problem:** Need to run `generate` first

**Solution:**
```bash
spt generate
spt install
```

#### "The following packages have unmet dependencies"
**Problem:** Missing dependencies in control file

**Solution:**
1. Edit control file:
   ```bash
   spt open
   # or
   code ~/.cache/spt/pkg/*/DEBIAN/control
   ```

2. Add missing dependencies:
   ```
   Depends: bash (>= 4.0), curl, jq
   ```

3. Regenerate:
   ```bash
   spt generate
   spt install
   ```

#### "trying to overwrite '/usr/bin/xyz'"
**Problem:** Conflicting package already installed

**Solution:**
```bash
# Remove conflicting package first
sudo apt remove conflicting-package

# Then install
spt install
```

### Permission Issues

#### "Permission denied" when editing files
**Problem:** Some files owned by root

**Solution:**
1. When using VSCode, grant permission when prompted
2. Or change ownership:
   ```bash
   PKG=$(ls ~/.cache/spt/pkg)
   sudo chown -R $USER:$USER ~/.cache/spt/pkg/$PKG
   ```

#### "Unable to create cache directory"
**Problem:** No write permission to ~/.cache

**Solution:**
```bash
# Check permissions
ls -la ~/.cache

# Fix if needed
chmod 755 ~/.cache
```

### Performance Issues

#### "Cache directory too large"
**Problem:** Old packages consuming disk space

**Solution:**
```bash
# Check size
du -sh ~/.cache/spt

# List packages
spt list

# Clean cache
spt clean -f
```

### Validation Issues

#### "Package installs but command not found"
**Problem:** Incorrect PATH or file placement

**Solution:**
1. Verify installation:
   ```bash
   dpkg -L package-name | grep /usr/bin
   ```

2. Check if file is executable:
   ```bash
   ls -la /usr/bin/package-name
   ```

3. Verify it's in PATH:
   ```bash
   echo $PATH | grep /usr/bin
   ```

4. Fix in pre-package if needed:
   ```bash
   spt open
   # Ensure files are in correct locations
   spt generate
   spt install
   ```

#### "Package installs but script fails"
**Problem:** Incorrect paths in script

**Solution:**
Edit main script to use correct paths:
```bash
# In your main script file
script_dir="/usr/share/package-name"  # Not relative path

# Source libraries
source "$script_dir/lib/utils.sh"
```

### Network Issues

#### "curl: Failed to connect"
**Problem:** Network connectivity or GitHub API issues

**Solution:**
1. Check internet:
   ```bash
   ping -c 3 github.com
   ```

2. Check GitHub status: https://www.githubstatus.com/

3. Try with verbose output:
   ```bash
   curl -v https://api.github.com/repos/username/repo
   ```

4. Wait and retry if GitHub API is down

#### "API rate limit exceeded"
**Problem:** Too many API calls (60/hour without auth)

**Solution:**
```bash
# Authenticate to get 5000/hour limit
gh auth login

# Check rate limit status
gh api rate_limit
```

### Architecture Issues

#### "wrong architecture"
**Problem:** Package built for wrong architecture

**Solution:**
1. Check your architecture:
   ```bash
   dpkg --print-architecture
   ```

2. Rebuild with correct architecture:
   ```bash
   spt clean
   spt create username/repo
   # When prompted, enter correct architecture (e.g., amd64, arm64)
   spt generate
   ```

3. Or use "all" for architecture-independent packages

## Debugging Tips

### Enable verbose output

Add debug output to troubleshoot:
```bash
# In create.sh or generate.sh
set -x  # Enable command tracing
# ... your debugging code ...
set +x  # Disable command tracing
```

### Check package contents

```bash
# List files in pre-package
find ~/.cache/spt/pkg/*/

# List files in .deb
dpkg-deb -c ~/.cache/spt/deb/*.deb

# Show package info
dpkg-deb -I ~/.cache/spt/deb/*.deb
```

### Validate control file

```bash
# Check syntax
dpkg-deb --info ~/.cache/spt/pkg/*/DEBIAN/control

# Validate dependencies
dpkg-checkdeps ~/.cache/spt/pkg/*/DEBIAN/control
```

### Manual package building

If SPT fails, try manually:
```bash
cd ~/.cache/spt/pkg
dpkg-deb --build package-name-dir/ ../deb/
```

### Check system logs

```bash
# Check apt logs
cat /var/log/apt/term.log | tail -50

# Check dpkg logs
cat /var/log/dpkg.log | tail -50
```

## Getting Help

If none of these solutions work:

1. **Check SPT version:**
   ```bash
   spt --version
   ```

2. **List your environment:**
   ```bash
   uname -a
   dpkg --version
   gh --version
   ```

3. **Gather debug info:**
   ```bash
   spt list
   ls -la ~/.cache/spt/
   ```

4. **Create an issue:**
   - Go to https://github.com/shinokada/spt/issues
   - Include version info, error messages, and steps to reproduce

## Quick Reference

### Reset everything
```bash
spt clean -f
```

### Start fresh
```bash
spt clean -f
spt create username/repo
spt generate
```

### Verify installation
```bash
# Check if package installed
dpkg -l | grep package-name

# Check installed files
dpkg -L package-name

# Test command
which package-name
package-name --version
```

### Completely remove a package
```bash
sudo apt remove --purge package-name
```
