FROM cachyos/cachyos:latest

# Enable multilib repository
RUN printf "\n%s\n%s\n" '[multilib]' 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

# Enable this repository
RUN printf "\n%s\n%s\n" '[electronic-mango]' 'Server = https://github.com/Electronic-Mango/arch-repository/releases/latest/download' >> /etc/pacman.conf

# Import GPG keys
COPY keys/gpg-public-key.asc keys/gpg-fingerprint.asc /tmp/repository-keys/
RUN pacman-key --init \
    && pacman-key --add /tmp/repository-keys/gpg-public-key.asc \
    && pacman-key --finger "$(cat /tmp/repository-keys/gpg-fingerprint.asc )" \
    && pacman-key --lsign-key "$(cat /tmp/repository-keys/gpg-fingerprint.asc )" \
    && rm /tmp/repository-keys/gpg-public-key.asc /tmp/repository-keys/gpg-fingerprint.asc \
    && rmdir /tmp/repository-keys

# Update and install basic packages
RUN pacman -Suy --noconfirm --needed git sudo pacman-contrib namcap gnupg jq curl wget moreutils
RUN pacman -Scc --noconfirm

# Create unprivileged user for building packages
RUN useradd --uid 1001 --create-home --shell /bin/bash --user-group --groups wheel builder \
    && echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel \
    && chmod 0440 /etc/sudoers.d/wheel

# Use unprivileged user as default
USER builder
WORKDIR /home/builder