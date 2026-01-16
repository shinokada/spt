fn_open(){
    echo "Looking for pre-package ..."
    
    # Find the pre-package directory
    PKG_NAME=$(ls -1 "$PKG_DIR" 2>/dev/null | head -1)
    
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
        echo "VSCode not found. Install it or use your preferred editor:"
        echo "  $EDITOR $PKG_PATH"
        exit 1
    fi
}
