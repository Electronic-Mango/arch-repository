# Maintainer: Electronic-Mango <78230210+Electronic-Mango@users.noreply.github.com>

_pkgname='xwayland-satellite'
pkgname="${_pkgname}-cursor-scaling-fix"
pkgver=0.8.2
pkgrel=1
pkgdesc="Xwayland outside your Wayland (with cursor scaling fix)"
arch=(x86_64)
url="https://github.com/Supreeeme/${_pkgname}"
license=(MPL-2.0)
provides=("${_pkgname}")
conflicts=("${_pkgname}" "${_pkgname}-git")
options=(strip !debug lto)

depends=(
  glibc
  libgcc
  libxcb
  xcb-util-cursor
  xorg-xwayland
)
makedepends=(
  git
  clang
  rust
)

source=("git+${url}.git")
sha512sums=(SKIP)
b2sums=(SKIP)

pkgver() {
  cd ${_pkgname}
  git describe --long --abbrev=7 | sed -e 's/^v//' -e 's/\([^-]*-g\)/r\1/' -e 's/-/./g'
}

prepare() {
  cd "${_pkgname}"
  git config user.name "local"
  git config user.email "<>"
  git pull origin pull/423/head --no-ff --no-commit
  sed 's|/usr/local|/usr|' -i "resources/${_pkgname}.service"
  export CARGO_HOME="${srcdir}/.cargo"
  cargo fetch --locked --target "$(rustc --print host-tuple)"
}

build() {
  cd "${_pkgname}"
  export CARGO_HOME="${srcdir}/.cargo"
  export RUSTFLAGS="--remap-path-prefix=$srcdir=/"
  cargo build --frozen --release --features systemd
}

check() {
  cd "${_pkgname}"
  export XDG_RUNTIME_DIR="$(mktemp -d)"
  export CARGO_HOME="${srcdir}/.cargo"
  cargo test --frozen
}

package() {
  cd "${_pkgname}"
  install -vDm 755 "target/release/${_pkgname}" -t "${pkgdir}/usr/bin/"
  install -vDm 644 "resources/${_pkgname}.service" -t "${pkgdir}/usr/lib/systemd/user/"
  install -vDm 644 "LICENSE" -t "${pkgdir}/usr/share/licenses/${pkgdir}/"
}
