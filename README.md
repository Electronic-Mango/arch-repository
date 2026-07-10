# Arch Repository

My own, custom software repository for Arch Linux.

The repository is hosted as a [GitHub Release](https://github.com/Electronic-Mango/arch-repository/releases/tag/repo-latest).

## Installation

Add repository configuration to `/etc/pacman.conf`:

```conf
[electronic-mango]
Server = https://github.com/Electronic-Mango/arch-repository/releases/latest/download
```

> **The repository must be named `electronic-mango`, otherwise `pacman` won't find the repository database file!**

Either disable signature verification by also adding:

```conf
SigLevel = Optional TrustAll
```

Or import the available GPG public key and fingerprint through bash:

```bash
sudo pacman-key --add gpg-public-key.asc
pacman-key --finger $(cat ./gpg-fingerprint.asc )
sudo pacman-key --lsign-key $(cat ./gpg-fingerprint.asc )
```

And update the repositories:

```bash
sudo pacman -Suy
```
