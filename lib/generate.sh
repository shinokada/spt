#!/usr/bin/env bash
# shellcheck shell=bash

fn_generate() {
    # Check for package in PKG_DIR first (before using PKG_NAME)
    PKG_NAME=$(find "$PKG_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1 | xargs -r basename 2>/dev/null)

    if [ -z "$PKG_NAME" ]; then
        echo "Error: No pre-package found in $PKG_DIR"
        echo "Please run 'spt create username/repo' first"
        exit 1
    fi

    OUTPUT_DIR="${OUTPUT:-$DEB_DIR}"
    PKG_PATH="$PKG_DIR/$PKG_NAME"
    OUTPUT_PATH="$OUTPUT_DIR/${PKG_NAME}.deb"

    # Remove only the target output file if it exists
    if [ -f "$OUTPUT_PATH" ]; then
        echo "Overwriting existing package: $OUTPUT_PATH"
        rm -f "$OUTPUT_PATH" || {
            echo "Error: Unable to overwrite existing package: $OUTPUT_PATH"
            exit 1
        }
    fi

    # Use custom output dir if specified
    OUTPUT_DIR="${OUTPUT:-$DEB_DIR}"

    # Create output directory
    echo "Creating output directory ..."
    mkdir -p "$OUTPUT_DIR" || {
        echo "Error: Unable to create output directory: $OUTPUT_DIR"
        exit 1
    }

    # Check for dpkg-deb
    echo "Checking dpkg-deb ..."
    if ! command -v dpkg-deb >/dev/null 2>&1; then
        echo "Error: dpkg-deb not found. Install it with: sudo apt install dpkg"
        exit 1
    fi

    echo "Found pre-package: $PKG_NAME"

    # Validate package structure
    echo "Validating package structure ..."
    if [ ! -f "$PKG_PATH/DEBIAN/control" ]; then
        echo "Error: Missing DEBIAN/control file"
        exit 1
    fi

    if [ ! -d "$PKG_PATH/usr/bin" ] && [ ! -d "$PKG_PATH/usr/share" ]; then
        echo "Warning: Package seems empty (no files in usr/bin or usr/share)"
    fi

    # Check for common issues
    if [ -d "$PKG_PATH/.git" ]; then
        echo "Warning: .git directory found in package (will be included in .deb)"
        if [ "${DRYRUN:-0}" != 1 ]; then
            if [ -t 0 ]; then
                read -r -p "Remove .git directory? [y/N] " response || true
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    rm -rf "$PKG_PATH/.git"
                    echo "Removed .git directory"
                fi
            else
                rm -rf "$PKG_PATH/.git"
                echo "Removed .git directory (non-interactive)"
            fi
        fi
    fi

    # Dry run mode
    if [ "${DRYRUN:-0}" = 1 ]; then
        echo ""
        echo "=== DRY RUN MODE ==="
        echo "Would build package:"
        echo "  Source: $PKG_PATH"
        echo "  Output: $OUTPUT_PATH"
        echo ""
        echo "Package contents:"
        find "$PKG_PATH" -type f | sed 's|'"$PKG_PATH"'||' | sort
        echo ""
        echo "Package size:"
        du -sh "$PKG_PATH" | cut -f1
        echo ""
        echo "Control file:"
        cat "$PKG_PATH/DEBIAN/control"
        echo ""
        echo "=== END DRY RUN ==="
        exit 0
    fi

    echo "Generating Debian package ..."

    # Build the package
    if dpkg-deb --build "$PKG_PATH" "$OUTPUT_PATH" 2>&1; then
        echo ""
        echo "✓ Debian package created successfully!"
        echo "  Location: $OUTPUT_PATH"

        # Show package info
        if command -v dpkg-deb >/dev/null 2>&1; then
            echo ""
            echo "Package information:"
            dpkg-deb -I "$OUTPUT_PATH" | grep -E "Package:|Version:|Architecture:|Maintainer:|Description:" | sed 's/^/  /'

            echo ""
            echo "Package size:"
            du -sh "$OUTPUT_PATH" | cut -f1 | sed 's/^/  /'
        fi

        # Run lintian if available
        if command -v lintian >/dev/null 2>&1; then
            echo ""
            echo "Running lintian checks ..."
            if lintian "$OUTPUT_PATH" 2>&1 | head -20; then
                echo "  (showing first 20 issues, if any)"
            fi
        fi

        echo ""
        echo "Next steps:"
        echo "  1. Test locally: spt install"
        echo "  2. Upload to GitHub releases"
        echo "  3. Install from release: sudo apt install ./$(basename "$OUTPUT_PATH")"
    else
        echo "Error: Failed to create Debian package"
        echo "Check the error messages above for details"
        exit 1
    fi
}
