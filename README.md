# Simple Pacakge Tool (SPT)

## Overview

This generates a basic DEBIAN package from Github-name/repo-name.

[Read more details here.](https://betterprogramming.pub/how-to-create-a-basic-debian-package-927be001ad80)

## Requirement

- Linux/Debian

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

2. Update the pre-deb package

   ```sh
   $ code /home/shinichi/.cache/debtemp/pkg/yourRepo_1.0.1-1_all
   ```

   a. Update Depends in `DEBIAN/control`.

   b. Update script_dir in `usr/bin/your-script`.

   ```bash
   script_dir="/usr/share/teffects"
   ```

3. Run `spt generate` to create a debian package.
4. Upload it to GitHub.
5. You can install it locally:

    ```sh
    $ sudo apt install /home/yourname/.cache/spt/deb/debian-package-name
    ```

## Author

Shinichi Okada

## License

Please see license.txt.
