fn_create(){
    # if $1 not there exit
    if [ $# -eq 0 ]; then
        echo "No arguments provided. Use spt create username/repo"
        exit 1
    else
        # check a slash in username/repo-name
        slash_num=$(echo "$1" | grep -o "/" | wc -l)
        if [ ! "$slash_num" -eq 1 ]; then
            echo "Usage: spt create username/repo"
            exit 1
        fi
    fi

    ### checking
    echo "Checking OS ..."
    if [[ ! $(uname) == "Linux" ]]; then
        echo "Error: You need to run this on Linux."
        exit 1
    fi

    # gh
    echo "Checking GitHub CLI ..."
    if ! command -v gh >/dev/null 2>&1; then
        echo "Error: Please install gh from https://github.com/cli/cli#installation."
        exit 1
    fi

    # check if you are logged in github
    echo "Checking Github login status ..."
    if ! gh auth status >/dev/null 2>&1; then
        echo "Error: You must be logged in. Use 'gh auth login'."
        exit 1
    fi

    # check DEBTEMP_DIR if not create it
    if [ ! -d "$DEBTEMP_DIR" ]; then
        mkdir -p "$DEBTEMP_DIR" || {
            echo "Error: Unable to create cache directory."
            exit 1
        }
    else
        # remove all files in ${DEBTEMP_DIR} (no sudo needed for user-owned dir)
        rm -rf "${DEBTEMP_DIR:?}/"* 2>/dev/null || true
        echo "Cache directory cleaned."
    fi

    # create PKG_DIR
    echo "Creating package directory ..."
    mkdir -p "$PKG_DIR" || {
        echo "Error: Unable to create package directory."
        exit 1
    }

    # get REPO_NAME and USER from $1
    REPO_USER=$(first "/" "$1")
    REPO_NAME=$(second "/" "$1")
    
    echo "Repository: ${REPO_USER}/${REPO_NAME}"
    
    echo "Fetching repository information ..."
    
    # Check if jq is available for better JSON parsing
    if command -v jq >/dev/null 2>&1; then
        # Use jq for reliable JSON parsing
        API_RESPONSE=$(curl -sH "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/${REPO_USER}/${REPO_NAME}/releases/latest" 2>/dev/null)
        
        if [ -z "$API_RESPONSE" ] || [ "$(echo "$API_RESPONSE" | jq -r '.message // empty')" = "Not Found" ]; then
            echo "Error: Could not find repository ${REPO_USER}/${REPO_NAME} or it has no releases."
            echo "Please ensure:"
            echo "  1. The repository exists and is accessible"
            echo "  2. The repository has at least one release"
            exit 1
        fi
        
        REPO_VERSION=$(echo "$API_RESPONSE" | jq -r '.tag_name | ltrimstr("v")')
        REPO_DESC=$(curl -s "https://api.github.com/repos/${REPO_USER}/${REPO_NAME}" | jq -r '.description // "No description"')
    else
        # Fallback to grep-based parsing
        HTML=$(curl -sH "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/${REPO_USER}/${REPO_NAME}/releases/latest" 2>/dev/null | grep "tag_name") || {
            echo "Error: Could not find repository ${REPO_USER}/${REPO_NAME} or it has no releases."
            echo "Tip: Install 'jq' for better JSON parsing: sudo apt install jq"
            exit 1
        }

        string="${HTML##*: \"v}"
        string="${HTML##*: \"}"
        string1="${string//\"/}"
        REPO_VERSION="${string1//,/}"
        
        # Get description
        REPO_DESC_RAW=$(curl -s "https://api.github.com/repos/${REPO_USER}/${REPO_NAME}" | grep "description")
        desc="${REPO_DESC_RAW##*: \"}"
        REPO_DESC="${desc//\",/}"
    fi
    
    # Validate version was found
    if [ -z "$REPO_VERSION" ] || [ "$REPO_VERSION" = "null" ]; then
        echo "Error: Could not determine version for ${REPO_USER}/${REPO_NAME}"
        echo "Please ensure the repository has at least one release with a version tag"
        exit 1
    fi

    echo "Fetching user information ..."
    # get Full name and email from git config
    UNAME=$(git config --get user.name 2>/dev/null || echo "")
    USER_NAME="${UNAME:-Unknown}"
    UEMAIL=$(git config --get user.email 2>/dev/null || echo "")
    USER_EMAIL="${UEMAIL:-unknown@example.com}"

    # Auto-detect architecture
    if command -v dpkg >/dev/null 2>&1; then
        ARCHITECTURE=$(dpkg --print-architecture 2>/dev/null || echo "all")
    else
        ARCHITECTURE="all"
    fi

    # Interactive confirmations (skip if --yes flag is set)
    if [ "${YES:-0}" != 1 ]; then
        read -r -e -i "$REPO_NAME" -p "Package name: " input
        REPO_NAME="${input:-$REPO_NAME}"

        read -r -e -i "$REPO_VERSION" -p "Version: " input
        REPO_VERSION="${input:-$REPO_VERSION}"

        REVISION_NUM=1
        read -r -e -i "$REVISION_NUM" -p "Revision number: " input
        REVISION_NUM="${input:-$REVISION_NUM}"

        read -r -e -i "$ARCHITECTURE" -p "Architecture: " input
        ARCHITECTURE="${input:-$ARCHITECTURE}"

        read -r -e -i "$REPO_DESC" -p "Description: " input
        REPO_DESC="${input:-$REPO_DESC}"
    else
        REVISION_NUM=1
        echo "Using defaults: ${REPO_NAME} ${REPO_VERSION}-${REVISION_NUM} ${ARCHITECTURE}"
    fi

    # PACKAGE_NAME_VersionNumber-RevisionNumber_DebianArchitecture
    DEB_NAME="${REPO_NAME}_${REPO_VERSION}-${REVISION_NUM}_${ARCHITECTURE}"

    # create directory structure
    echo "Creating directory structure ..."
    mkdir -p "$PKG_DIR/$DEB_NAME/DEBIAN" \
             "$PKG_DIR/$DEB_NAME/usr/bin" \
             "$PKG_DIR/$DEB_NAME/usr/share/$REPO_NAME" || {
        echo "Error: Unable to create directory structure."
        exit 1
    }

    # create control file
    echo "Creating control file ..."
cat <<EOF >"$PKG_DIR/$DEB_NAME/DEBIAN/control"
Package: ${REPO_NAME}
Version: ${REPO_VERSION}
Architecture: ${ARCHITECTURE}
Maintainer: ${USER_NAME} <${USER_EMAIL}>
Depends: 
Homepage: https://github.com/${REPO_USER}/${REPO_NAME}
Description: ${REPO_DESC}

EOF

    # create preinst script
    echo "Creating preinst script ..."
cat <<EOF >"$PKG_DIR/$DEB_NAME/DEBIAN/preinst"
#!/bin/bash
# This removes an old version.

echo "Looking for old versions of ${REPO_NAME} ..."

if [ -f "/usr/bin/${REPO_NAME}" ]; then
    rm -f /usr/bin/${REPO_NAME}
    echo "Removed old ${REPO_NAME} from /usr/bin"
fi

if [ -d "/usr/share/${REPO_NAME}" ]; then
    rm -rf /usr/share/${REPO_NAME}
    echo "Removed old ${REPO_NAME} from /usr/share"
fi
EOF

    # clone the repo
    echo "Cloning repository ..."
    TARGET_DIR="$PKG_DIR/$DEB_NAME/usr/share/$REPO_NAME"
    
    # Try HTTPS first, fall back to SSH
    if ! git clone --quiet "https://github.com/${REPO_USER}/${REPO_NAME}.git" "$TARGET_DIR" 2>/dev/null; then
        echo "HTTPS clone failed, trying SSH ..."
        if ! git clone --quiet "git@github.com:${REPO_USER}/${REPO_NAME}.git" "$TARGET_DIR" 2>/dev/null; then
            echo "Error: Unable to clone repository. Please check:"
            echo "  1. Repository exists and is accessible"
            echo "  2. You have proper authentication (try 'gh auth login')"
            exit 1
        fi
    fi

    # Detect main script automatically
    echo "Detecting main executable ..."
    MAIN_SCRIPT=""
    
    # Look for executable file matching repo name
    if [ -f "$TARGET_DIR/${REPO_NAME}" ] && [ -x "$TARGET_DIR/${REPO_NAME}" ]; then
        MAIN_SCRIPT="${REPO_NAME}"
    else
        # Find any executable file
        MAIN_SCRIPT=$(find "$TARGET_DIR" -maxdepth 1 -type f -executable ! -name ".*" -printf "%f\n" | head -1)
    fi
    
    if [ -z "$MAIN_SCRIPT" ]; then
        echo "Warning: Could not automatically detect main executable."
        echo "Available files in repository:"
        ls -1 "$TARGET_DIR" | head -10
        
        if [ "${YES:-0}" != 1 ]; then
            read -r -p "Enter the main script filename: " MAIN_SCRIPT
            if [ -z "$MAIN_SCRIPT" ] || [ ! -f "$TARGET_DIR/$MAIN_SCRIPT" ]; then
                echo "Error: Invalid script name"
                exit 1
            fi
        else
            echo "Error: Cannot proceed in non-interactive mode without main script"
            exit 1
        fi
    fi

    echo "Moving main script to /usr/bin ..."
    # Move the main script to usr/bin
    if [ -f "$TARGET_DIR/$MAIN_SCRIPT" ]; then
        mv "$TARGET_DIR/$MAIN_SCRIPT" "$PKG_DIR/$DEB_NAME/usr/bin/${REPO_NAME}" || {
            echo "Error: Unable to move main script"
            exit 1
        }
    else
        echo "Error: Main script not found: $TARGET_DIR/$MAIN_SCRIPT"
        exit 1
    fi

    echo "Setting permissions ..."
    # change the permissions (only if needed - for files that will be installed system-wide)
    chmod 755 "$PKG_DIR/$DEB_NAME/usr/bin/${REPO_NAME}"
    chmod 755 "$PKG_DIR/$DEB_NAME/DEBIAN/preinst"
    
    # Set ownership only for files that need it
    # No sudo needed for user cache directory
    chmod -R u+rwX,go+rX "$PKG_DIR/$DEB_NAME"

    echo ""
    echo "✓ Pre-package created successfully!"
    echo "  Location: $PKG_DIR/$DEB_NAME"
    echo ""
    
    if [ "${CODE:-0}" = 1 ]; then
        if command -v code >/dev/null 2>&1; then
            echo "Opening in VSCode ..."
            code "$PKG_DIR/$DEB_NAME" || {
                echo "Warning: Unable to open in VSCode"
            }
        else
            echo "Warning: VSCode not found in PATH"
        fi
    else
        echo "Tip: Use 'spt open' or 'code $PKG_DIR/$DEB_NAME' to edit"
    fi
    
    echo ""
    echo "Next steps:"
    echo "  1. Review/edit the package: $PKG_DIR/$DEB_NAME"
    echo "  2. Update dependencies in: $PKG_DIR/$DEB_NAME/DEBIAN/control"
    echo "  3. Generate .deb package: spt generate"
}
