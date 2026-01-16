fn_clean(){
    if [ ! -d "$DEBTEMP_DIR" ]; then
        echo "Cache directory does not exist: $DEBTEMP_DIR"
        echo "Nothing to clean."
        exit 0
    fi
    
    # Show what will be deleted
    CACHE_SIZE=$(du -sh "$DEBTEMP_DIR" 2>/dev/null | cut -f1)
    echo "Cache directory: $DEBTEMP_DIR"
    echo "Current size: $CACHE_SIZE"
    echo ""
    
    # Count items
    PKG_COUNT=0
    DEB_COUNT=0
    
    if [ -d "$PKG_DIR" ]; then
        PKG_COUNT=$(find "$PKG_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
    fi
    
    if [ -d "$DEB_DIR" ]; then
        DEB_COUNT=$(find "$DEB_DIR" -name "*.deb" 2>/dev/null | wc -l)
    fi
    
    echo "Items to be removed:"
    echo "  • $PKG_COUNT pre-package(s)"
    echo "  • $DEB_COUNT .deb package(s)"
    echo ""
    
    # Confirm unless --force flag is set
    if [ "${FORCE:-0}" != 1 ]; then
        read -r -p "Are you sure you want to clean the cache? [y/N] " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Cancelled."
            exit 0
        fi
    fi
    
    # Remove cache directory
    echo "Cleaning cache ..."
    if rm -rf "$DEBTEMP_DIR"; then
        echo "✓ Cache cleaned successfully!"
        echo "  Freed: $CACHE_SIZE"
    else
        echo "Error: Failed to clean cache directory"
        exit 1
    fi
}
