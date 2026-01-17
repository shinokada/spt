#!/usr/bin/env bash
# shellcheck shell=bash

fn_open() {
    echo "Looking for pre-package ..."

    if [ -z "$PKG_DIR" ]; then
        echo "Error: PKG_DIR is not set"
        exit 1
    fi

    # Find the pre-package directory
    # Use glob to get first directory entry safely
    for entry in "$PKG_DIR"/*; do
        if [ -e "$entry" ]; then
            PKG_NAME=$(basename "$entry")
            break
        fi
    done

    if [ -z "$PKG_NAME" ]; then
        echo "Error: No pre-package found in $PKG_DIR"
        echo "Please run 'spt create username/repo' first"
        exit 1
    fi

    PKG_PATH="$PKG_DIR/$PKG_NAME"

    echo "Found pre-package: $PKG_NAME"
    echo "Location: $PKG_PATH"
    echo ""

    # Try to open with VSCode
    if command -v code >/dev/null 2>&1; then
        echo "Opening in VSCode ..."
        code "$PKG_PATH" || {
            echo "Error: Unable to open VSCode"
            exit 1
        }
        echo "✓ Opened in VSCode"
        echo ""
        echo "Note: When saving, you may need to grant permission since"
        echo "      some files are owned by root."
    else
        echo "VSCode not found."
        if [ -n "$EDITOR" ]; then
            echo "Opening with \$EDITOR ($EDITOR)..."
            "$EDITOR" "$PKG_PATH" || {
                echo "Error: Unable to open with $EDITOR"
                exit 1
            }
        else
            echo "No editor configured. Set \$EDITOR or install VSCode."
            echo "Example: export EDITOR=vim"
            exit 1
        fi
    fi
}
