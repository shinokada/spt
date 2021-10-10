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
    dpkg-deb --build "$PKG_DIR/$PKG_NAME" "$DEB_DIR"|| {
        echo "Not able to create a debian package."
        exit
    }

    echo "Your Debian package is in the $DEB_DIR directory."
    DEB_NAME=$(ls "$DEB_DIR")
    echo "Next upload $DEB_DIR/$DEB_NAME to your GitHub account."
    echo "Then run: sudo apt install $DEB_DIR/$DEB_NAME"
}