FROM archlinux:base-devel

# Enable multilib repository
RUN printf "%s\n%s" '[multilib]' 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

# Update and install basic packages
RUN pacman-key --init
RUN pacman -Suy --noconfirm --needed git sudo pacman-contrib namcap gnupg jq curl
RUN pacman -Scc --noconfirm

# Create unprivileged user for building packages
RUN useradd --uid 1001 --create-home --shell /bin/bash --user-group --groups wheel builder \
    && echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel \
    && chmod 0440 /etc/sudoers.d/wheel

# Use unprivileged user as default
USER builder
WORKDIR /home/builder