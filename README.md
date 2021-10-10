# Debtemp

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

## Usage

1. Create a pre-deb package

   ```sh
   $ debtemp create shinokada/teffects
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

3. Run `debtemp generate` to create a debian package.
4. Upload it to GitHub.
5. You can install it locally:

    ```sh
    $ sudo apt install /home/yourname/.cache/debtemp/deb/debian-package-name
    ```

## Author

Shinichi Okada

## License

Please see license.txt.
