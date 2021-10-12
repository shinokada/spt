fn_create(){
    # if $1 not there exit
    if [ $# -eq 0 ]; then
        echo "No arguments provided. Use debtemp create username/repo"
        exit 1
    else
        # check a slash in shinokada/repo-name
        slash_num=$(echo "$1" | grep -o "/" | wc -l)
        if [ ! "$slash_num" -eq 1 ]; then
            echo "Use username/repo"
            exit
        fi
    fi

    ### checking
    echo "Checking OS ..."
    if [[ ! $(uname) == "Linux" ]]; then
        echo "You need to run this on Linux."
        exit 1
    fi

    # gh
    echo "Checking GitHub cli ..."
    if [ ! "$(command -v gh)" ]; then
        echo "Please install gh from https://github.com/cli/cli#installation."
        exit 1
    fi

    # check if you are logged in github
    echo "Checking Github login status ..."
    if [[ $(gh auth status) -eq 1 ]]; then
        # not logged-in
        echo ">>> You must logged in. Use 'gh auth login'."
        exit 1
    fi

    # check DEBTEMP_DIR if not create it
    if [ ! -d "$DEBTEMP_DIR" ]; then
        mkdir -p "$DEBTEMP_DIR" || {
            echo "Not able to create a dir."
            exit 1
        }
    else
        # remove all files in ${DEBTEMP_DIR}
        sudo rm -rf "${DEBTEMP_DIR:?}/"* || {
            echo "Not able to clean the cache dir."
            exit 1
        }
        echo "Files in cache dir are removed."
    fi

    # create PKG_DIR and DEB_DIR
    echo "Creating the pkg dir ..."
    mkdir -p "$PKG_DIR" || {
        echo "Not able to create dirs"
        exit 1
    }

    # get REPO_NAME and USER from $1
    REPO_USER=$(first "/" "$1")
    REPO_NAME=$(second "/" "$1")
    # echo "$REPO_USER"
    # echo "$REPO_NAME"
    echo "Checking your Github user name and email ..."
    # get Full name and email from git log --list
    UNAME=$(git config --list | grep user.name)
    USER_NAME=$(second "=" "$UNAME")
    UEMAIL=$(git config --list | grep user.email)
    USER_EMAIL=$(second "=" "$UEMAIL")

    echo "Checking the repo latest version ..."
    # get the version from curl
    HTML=$(curl -sH "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/${REPO_USER}/${REPO_NAME}/releases/latest" | grep "tarball_url") || {
        echo "Not able to find the repo ${REPO_USER}/${REPO_NAME}."
        exit 1
    }

    string="${HTML##*/v}"
    string1="${string//\"/}"

    REPO_VERSION="${string1//,/}"
    # echo "$REPO_VERSION"

    # Get description
    REPO_DESC=$(curl -s https://api.github.com/repos/${REPO_USER}/${REPO_NAME} | grep description)

    desc="${REPO_DESC##*: \"}"
    REPO_D="${desc//\",/}"

    # read (to confirm)
    read -r -e -i "$REPO_NAME" -p "Please enter your repo name: " input
    REPO_NAME="${input:-$REPO_NAME}"

    read -r -e -i "$REPO_VERSION" -p "Please enter your repo version: " input
    REPO_VERSION="${input:-$REPO_VERSION}"

    REVISION_NUM=1
    read -r -e -i "$REVISION_NUM" -p "Please enter your revision number: " input
    REVISION_NUM="${input:-$REVISION_NUM}"

    read -r -e -i "$ARCHITECTURE" -p "Please enter your architecture: " input
    ARCHITECTURE="${input:-$ARCHITECTURE}"

    read -r -e -i "$REPO_D" -p "Please enter the description: " input
    REPO_D="${input:-$REPO_D}"

    # PACKAGE_NAME_VersionNumber-RevisionNumber_DebianArchitecture
    DEB_NAME="${REPO_NAME}_${REPO_VERSION}-${REVISION_NUM}_${ARCHITECTURE}"

    # create dirs PKG_DIR/${DEB_NAME}/DEBIAN, PKG_DIR/${DEB_NAME}/usr/bin, PKG_DIR/${DEB_NAME}/usr/share/$1 where $1 is the first parameter in pkg_code
    echo "Creating directories ..."
    mkdir -p "$PKG_DIR/$DEB_NAME/DEBIAN" "$PKG_DIR/$DEB_NAME/usr/bin" "$PKG_DIR/$DEB_NAME/usr/share/$REPO_NAME"

    # create/copy files to PKG_DIR/${DEB_NAME}/DEBIAN/control, PKG_DIR/${DEB_NAME}/DEBIAN/preinst

cat <<EOF >"$PKG_DIR/$DEB_NAME/DEBIAN/control"
Package: ${REPO_NAME}
Version: ${REPO_VERSION}
Architecture: ${ARCHITECTURE}
Maintainer: ${USER_NAME}<${USER_EMAIL}>
Depends:
Homepage: https://github.com/${REPO_USER}/${REPO_NAME}
Description: ${REPO_D}

EOF

cat <<EOF >"$PKG_DIR/$DEB_NAME/DEBIAN/preinst"
#!/bin/bash
# This removes an old version.

echo "Looking for old versions of ${REPO_NAME} ..."

if [ -f "/usr/bin/${REPO_NAME}" ]; then
    sudo rm -f /usr/bin/${REPO_NAME}
    echo "Removed the old ${REPO_NAME} from /usr/bin ..."
fi

if [ -d "/usr/share/${REPO_NAME}" ]; then
    sudo rm -rf /usr/share/${REPO_NAME}
    echo "Removed the old ${REPO_NAME} from /usr/share ..."
fi
EOF

    # clone the repo to "$PKG_DIR/$DEB_NAME/usr/share/$REPO_NAME"
    echo "Cloning the repo ..."
    TARGET_DIR="$PKG_DIR/$DEB_NAME/usr/share/$REPO_NAME"
    git clone --quiet git@github.com:"${REPO_USER}/${REPO_NAME}".git "$TARGET_DIR" || exit

    echo "Moving the main file to $PKG_DIR/$DEB_NAME/usr/bin ..."
    # Move the main script to usr/bin/${REPO_NAME}
    mv "$TARGET_DIR/${REPO_NAME}" "$PKG_DIR/$DEB_NAME/usr/bin"

    echo "Changing permissions ..."
    # change the permission
    sudo chown root:root -R "$PKG_DIR/$DEB_NAME"
    sudo chmod 755 "$PKG_DIR/$DEB_NAME/usr/bin/$REPO_NAME"
    sudo chmod 755 "$PKG_DIR/$DEB_NAME/DEBIAN/preinst"

    echo "The package is created in $PKG_DIR/$DEB_NAME."
    if [ "$CODE" = 1 ];then
        echo "Opening it with VSCode ..."
        code "$PKG_DIR/$DEB_NAME" || {
            echo "Not able to open in VSCode."
            exit 1
        }
    else
        echo "Open it to add additional information."
    fi
    echo "After that, run '${SCRIPT_NAME} generate' to generate a debian package."
}