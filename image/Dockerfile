FROM archlinux:base-devel

RUN pacman -Suy --noconfirm --needed git sudo pacman-contrib namcap gnupg jq curl
RUN pacman -Scc --noconfirm

RUN useradd --create-home --shell /bin/bash --user-group --groups wheel builder \
    && echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel \
    && chmod 0440 /etc/sudoers.d/wheel

USER builder
WORKDIR /home/builder