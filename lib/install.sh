fn_install(){
    echo "Installing the local Debian package ..."
    # generate deb package
    # cd "$PKG_DIR" || exit
    DEB_NAME=$(ls "$DEB_DIR")
    if [ -n "$DEB_NAME" ];then
    # echo "$PKG_DIR/$PKG_NAME"
        sudo apt install "$DEB_DIR/$DEB_NAME"|| {
            echo "Not able to install the local Debian package."
            exit
        }
    else
        echo "There is no Debian package. Please run 'spt generate'."
        exit 1
    fi

    echo "$DEB_NAME is installed."
}