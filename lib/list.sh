fn_list(){
    echo "SPT Cache Directory: $DEBTEMP_DIR"
    echo ""
    
    # Check if cache exists
    if [ ! -d "$DEBTEMP_DIR" ]; then
        echo "No cache directory found."
        echo "Run 'spt create username/repo' to create your first package."
        exit 0
    fi
    
    # List pre-packages
    echo "Pre-packages (staged for building):"
    if [ -d "$PKG_DIR" ] && [ -n "$(ls -A "$PKG_DIR" 2>/dev/null)" ]; then
        for pkg in "$PKG_DIR"/*; do
            if [ -d "$pkg" ]; then
                PKG_NAME=$(basename "$pkg")
                PKG_SIZE=$(du -sh "$pkg" 2>/dev/null | cut -f1)
                
                # Extract info from control file if it exists
                if [ -f "$pkg/DEBIAN/control" ]; then
                    VERSION=$(grep "^Version:" "$pkg/DEBIAN/control" | cut -d: -f2 | xargs)
                    ARCH=$(grep "^Architecture:" "$pkg/DEBIAN/control" | cut -d: -f2 | xargs)
                    echo "  • $PKG_NAME"
                    echo "    Version: $VERSION | Arch: $ARCH | Size: $PKG_SIZE"
                    echo "    Path: $pkg"
                else
                    echo "  • $PKG_NAME (incomplete - missing control file)"
                    echo "    Size: $PKG_SIZE"
                    echo "    Path: $pkg"
                fi
                echo ""
            fi
        done
    else
        echo "  (none)"
        echo ""
    fi
    
    # List generated .deb packages
    echo "Generated Debian packages (ready to install):"
    if [ -d "$DEB_DIR" ] && [ -n "$(ls -A "$DEB_DIR"/*.deb 2>/dev/null)" ]; then
        for deb in "$DEB_DIR"/*.deb; do
            if [ -f "$deb" ]; then
                DEB_NAME=$(basename "$deb")
                DEB_SIZE=$(du -sh "$deb" 2>/dev/null | cut -f1)
                
                # Get package info
                if command -v dpkg-deb >/dev/null 2>&1; then
                    PKG_NAME=$(dpkg-deb -f "$deb" Package 2>/dev/null)
                    VERSION=$(dpkg-deb -f "$deb" Version 2>/dev/null)
                    ARCH=$(dpkg-deb -f "$deb" Architecture 2>/dev/null)
                    
                    # Check if installed
                    INSTALLED=""
                    if dpkg -l "$PKG_NAME" 2>/dev/null | grep -q "^ii"; then
                        INSTALLED=" [INSTALLED]"
                    fi
                    
                    echo "  • $DEB_NAME$INSTALLED"
                    echo "    Package: $PKG_NAME | Version: $VERSION | Arch: $ARCH | Size: $DEB_SIZE"
                else
                    echo "  • $DEB_NAME"
                    echo "    Size: $DEB_SIZE"
                fi
                echo "    Path: $deb"
                echo ""
            fi
        done
    else
        echo "  (none)"
        echo ""
    fi
    
    # Show total cache size
    if [ -d "$DEBTEMP_DIR" ]; then
        TOTAL_SIZE=$(du -sh "$DEBTEMP_DIR" 2>/dev/null | cut -f1)
        echo "Total cache size: $TOTAL_SIZE"
        echo ""
        echo "Tip: Use 'spt clean' to remove all cached files"
    fi
}
