FROM ghcr.io/ublue-os/arch-distrobox AS box

LABEL com.github.containers.toolbox="true"

COPY extra-packages /
RUN grep -v '^#' /extra-packages | xargs pacman -Syu --noconfirm 
RUN rm /extra-packages



RUN   ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \ 
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update
     
RUN  rm -rf \
      /tmp/* \
      /var/cache/pacman/pkg/*

#####   desktop ####
FROM box AS box-desktop

LABEL name="box-desktop"

RUN pacman -Syu xdg-desktop-portal-kde --noconfirm

RUN  rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/*
