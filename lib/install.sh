#!/usr/bin/env bash
# shellcheck shell=bash

fn_install() {
    echo "Looking for Debian package ..."

    # Check if DEB_DIR exists
    if [ ! -d "$DEB_DIR" ]; then
        echo "Error: No .deb package found in $DEB_DIR"
        echo "Please run 'spt generate' first to create a package"
        exit 1
    fi

    # Find the .deb file
    DEB_FILES=$(find "$DEB_DIR" -maxdepth 1 -name "*.deb" -type f 2>/dev/null)
    if [ -z "$DEB_FILES" ]; then
        DEB_COUNT=0
    else
        DEB_COUNT=$(echo "$DEB_FILES" | wc -l)
    fi

    if [ "$DEB_COUNT" -gt 1 ]; then
        echo "Warning: Multiple .deb packages found. Using the first one."
        echo "Available packages:"
        echo "$DEB_FILES" | while read -r f; do echo "  - $(basename "$f")"; done
        echo ""
    fi

    DEB_FILE=$(printf '%s\n' "$DEB_FILES" | sort | head -1)

    if [ -z "$DEB_FILE" ]; then
        echo "Error: No .deb package found in $DEB_DIR"
        echo "Please run 'spt generate' first to create a package"
        exit 1
    fi

    DEB_NAME=$(basename "$DEB_FILE")
    echo "Found package: $DEB_NAME"

    # Show package information
    if command -v dpkg-deb >/dev/null 2>&1; then
        echo ""
        echo "Package information:"
        dpkg-deb -I "$DEB_FILE" | grep -E "Package:|Version:|Architecture:|Description:" | sed 's/^/  /'
    fi

    # Check if already installed (requires dpkg-deb)
    if command -v dpkg-deb >/dev/null 2>&1; then
        PACKAGE_NAME=$(dpkg-deb -f "$DEB_FILE" Package 2>/dev/null)
    else
        PACKAGE_NAME=""
    fi

    if [ -n "$PACKAGE_NAME" ]; then
        if dpkg -l "$PACKAGE_NAME" 2>/dev/null | grep -q "^ii"; then
            INSTALLED_VERSION=$(dpkg -l "$PACKAGE_NAME" | grep "^ii" | awk '{print $3}')
            NEW_VERSION=$(dpkg-deb -f "$DEB_FILE" Version 2>/dev/null)
            echo ""
            echo "Note: $PACKAGE_NAME is already installed (version: $INSTALLED_VERSION)"
            echo "      New version: $NEW_VERSION"
        fi
    fi

    echo ""
    echo "Installing $DEB_NAME ..."
    echo "This will require sudo privileges."
    echo ""

    # Install the package
    if sudo apt install "$DEB_FILE"; then
        echo ""
        echo "✓ Package installed successfully!"

        # Show installed files
        if [ -n "$PACKAGE_NAME" ] && command -v dpkg >/dev/null 2>&1; then
            echo ""
            echo "Installed files:"
            dpkg -L "$PACKAGE_NAME" 2>/dev/null | grep -E "^/usr/(bin|share)" | head -10 | sed 's/^/  /'

            TOTAL_FILES=$(dpkg -L "$PACKAGE_NAME" 2>/dev/null | wc -l)
            if [ "$TOTAL_FILES" -gt 10 ]; then
                echo "  ... and $((TOTAL_FILES - 10)) more files"
            fi
        fi
    else
        echo ""
        echo "Error: Failed to install package"
        echo "Common issues:"
        echo "  - Missing dependencies (check error messages above)"
        echo "  - Conflicting packages"
        echo "  - Insufficient permissions"
        echo ""
        echo "Try manually: sudo apt install $DEB_FILE"
        exit 1
    fi
}
