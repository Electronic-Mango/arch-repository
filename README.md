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


## Packages

### `visual-studio-code`

The official, Microsoft VS Code tarball.

Maintenance is done "manually", there's no upstream.

File `control` is a metadata file from `.deb` package.
It cannot be used directly in Arch, but it's useful for tracking dependency changes (which, unfortunately, need to be applied manually).


### `proton-cachyos-slr-v3`

Modified official CachyOS Proton package - [`proton-cachyos-slr`](https://github.com/CachyOS/CachyOS-PKGBUILDS/tree/master/proton-cachyos-slr).

There are a couple of changes:
 - Use `x86_64_v3` version, instead of regular `x86_64`
 - Modify `LogPixels` in default registry files to double DPI (`60` -> `c0`, or `96` -> `192`)
 - Change display name to `Proton CachyOS <version>`

The package is modified upstream of the original package, not fully custom one.


### `noctalia-meta`

A meta-package used for tracking runtime dependencies of [Noctalia v5](https://github.com/noctalia-dev/noctalia).
It isn't actually installed.

The dependencies and version is synchronized via [Noctalia's AUR package](https://aur.archlinux.org/packages/noctalia).