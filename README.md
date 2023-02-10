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
$ spt create github-name/repo-name
```

Use the `-c` or `--code` option to open the created pre-package in VSCode. When you save it, it will ask you the permission since the files' owner is the root.

2. Update the pre-deb package

```sh
$ code /home/shinichi/.cache/debtemp/pkg/your-app_1.0.1-1_all
```

a. Update Depends in `DEBIAN/control`.

b. Update script_dir in `usr/bin/your-app`.

```bash
script_dir="/usr/share/your-app"
```

3. Run `spt generate` to create a debian package.


```sh
$ spt generate
Creating the deb dirs ...
Checking dpkg-deb ...
Generating deb package ...
/home/ubuntu/.cache/spt/pkg/your-app_1.0.1-1_all
dpkg-deb: building package 'your-package' in '/home/ubuntu/.cache/spt/deb/your-app_1.0.1-1_all.deb'.
Your Debian package is in the /home/ubuntu/.cache/spt/deb directory.
Next upload /home/ubuntu/.cache/spt/deb/your-app_1.0.1-1_all.deb to your GitHub account.
Then run: sudo apt install /home/ubuntu/.cache/spt/deb/your-app_1.0.1-1_all
```

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
