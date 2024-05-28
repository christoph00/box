FROM ghcr.io/ublue-os/arch-distrobox AS box

LABEL com.github.containers.toolbox="true"

COPY extra-packages /
RUN grep -v '^#' /extra-packages | xargs pacman -Syu --noconfirm 
RUN rm /extra-packages



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

RUN paru -S xdg-desktop-portal-kde aur/visual-studio-code-bin --noconfirm

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

