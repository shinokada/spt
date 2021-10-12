fn_generate(){
    # clean $DEB_DIR directory
    rm -rf $DEB_DIR/*
    # create PKG_DIR and DEB_DIR
    echo "Creating the deb dirs ..."
    mkdir -p "$DEB_DIR" || {
        echo "Not able to create dirs"
        exit 1
    }
    # dpkg
    echo "Checking dpkg-deb ..."
    if [ ! "$(command -v dpkg-deb)" ]; then
        echo "Please install dpkg. Use 'sudo apt install dpkg'."
        exit 1
    fi

    echo "Generating deb package ..."
    # generate deb package
    # cd "$PKG_DIR" || exit
    PKG_NAME=$(ls "$PKG_DIR")
    if [ -n "$PKG_NAME" ];then
        echo "$PKG_DIR/$PKG_NAME"
        dpkg-deb --build "$PKG_DIR/$PKG_NAME" "$DEB_DIR/$PKG_NAME.deb"|| {
            echo "Not able to create a debian package."
            exit
        }
    else
        echo "There is no pre-Debian package. Please run 'spt create user/repo'."
        exit
    fi
    # mv "$PKG_DIR/"*.deb "$DEB_DIR"

    echo "Your Debian package is in the $DEB_DIR directory."
    DEB_NAME=$(ls "$DEB_DIR")
    echo "Next upload $DEB_DIR/$DEB_NAME to your GitHub account."
    echo "Then run: sudo apt install $DEB_DIR/$DEB_NAME"
}