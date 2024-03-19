<p align="center">
<a href='https://ko-fi.com/Z8Z2CHALG' target='_blank'><img height='42' style='border:0px;height:42px;' src='https://storage.ko-fi.com/cdn/kofi3.png?v=3' alt='Buy Me a Coffee at ko-fi.com' /></a>
</p>

# Simple Pacakge Tool (SPT)

## Overview

This generates a basic DEBIAN package from Github-name/repo-name.

[Read more details here.](https://betterprogramming.pub/how-to-create-a-basic-debian-package-927be001ad80)

## Requirement

- Linux/Debian
- curl
- dpkg

Debian/Ubuntu should have it. If not install it using apt.

```sh
$ sudo apt install dpkg
```

- GitHub CLI `gh`

## Installation

Download the latest debian package from the [releases](https://github.com/shinokada/spt/releases) page.

Run:

```sh
sudo apt install spt_XXXXX-X_XXX.deb
```

## Usage

1. Create a pre-deb package

   ```sh
   $ spt create shinokada/teffects
   ```

Use the `-c` or `--code` option to open the created pre-package in VSCode. When you save it, it will ask you the permission since the files' owner is the root.

2. Update the pre-deb package

   ```sh
   $ code $HOME/.cache/spt/pkg/yourRepo_1.0.1-1_all
   ```

   a. Update Depends in `DEBIAN/control`.

   If you are using vim:

   ```sh
   $ vim $HOME/.cache/spt/pkg/yourRepo_1.0.1-1_all/DEBIAN/control
   ```

   b. Update script_dir in `usr/bin/your-script`.

   ```bash
   script_dir="/usr/share/teffects"
   ```

3. Run `spt generate` to create a debian package.
4. Upload it to GitHub.
5. You can install it locally using the `spt install` command.

    ```sh
    $ spt install
    ```

    Or install it manually:

    ```sh
    $ sudo apt install /home/yourname/.cache/spt/deb/debian-package-name
    ```

## Author

Shinichi Okada

## License

Please see license.txt.
