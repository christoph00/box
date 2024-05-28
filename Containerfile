FROM ghcr.io/ublue-os/arch-distrobox AS box

LABEL com.github.containers.toolbox="true"

COPY extra-packages /
RUN grep -v '^#' /extra-packages | xargs pacman -Syu --noconfirm 
RUN rm /extra-packages

# Pacman Initialization
RUN sed -i 's/#Color/Color/g' /etc/pacman.conf && \
    printf "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" | tee -a /etc/pacman.conf && \
    sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf && \
    pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com && \
    pacman-key --lsign-key 3056513887B78AEB && \
    pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm && \
    printf "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" | tee -a /etc/pacman.conf && \
    pacman -Syu --noconfirm



RUN   ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \ 
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update &&\
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/systemctl

     
RUN  rm -rf \
      /tmp/* \
      /var/cache/pacman/pkg/*

#####   desktop ####
FROM box AS box-desktop

LABEL name="box-desktop"

# Create build user
RUN useradd -m --shell=/bin/bash build && usermod -L build && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


USER build

RUN grep -v '^#' /desktop-packages | xargs paru -Syu --noconfirm 



USER root
WORKDIR /

# Cleanup
RUN  sed -i 's/-march=x86-64 -mtune=generic/-march=native -mtune=native/g' /etc/makepkg.conf && \
    userdel -r build && \
    rm -drf /home/build && \
    sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/*

