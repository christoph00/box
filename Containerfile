ARG base_tag=40
ARG base_image=registry.fedoraproject.org/fedora-toolbox
FROM ${base_image}:${base_tag}

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used by distrobox -i <image-name> <container-name>"


COPY ["vscode.repo", "/etc/yum.repos.d/"]

RUN wget -O /tmp/thorium.rpm `curl -s https://api.github.com/repos/Alex313031/thorium/releases/latest| grep browser_download_url | grep '_AVX2.rpm' | head -n 1 | cut -d '"' -f 4` && \
    wget -O /tmp/wezterm.rpm `curl -s https://api.github.com/repos/wez/wezterm/releases/latest | grep browser_download_url | grep 'fedora39.x86_64.rpm' | head -n 1 | cut -d '"' -f 4`


RUN dnf update -y && dnf upgrade -y

RUN dnf install -y man

RUN dnf reinstall -y    \
    authselect          \
    authselect-libs     \
    ca-certificates     \
    cracklib-runtime    \
    crypto-policies     \
    expat               \
    filesystem          \
    file-libs           \
    libarchive          \
    libpwquality        \
    libsemanage         \
    pcre2-syntax        \
    shadow-utils

RUN dnf install -y      \
    bash-completion     \
    bind-utils          \
    jq                  \
    git                 \
    gitk                \
    git-lfs             \  
    gnupg2              \
    info                \
    iproute             \
    iputils             \
    make                \
    man                 \
    netcat              \
    net-tools           \
    nmap                \
    openssl             \
    traceroute          \
    unzip               \
    wget                \
    which               \
    nu                  \
    butane              \
    coreos-installer    \
    direnv              \
    qt-virt-manager     \
    code                \
    /tmp/thorium.rpm    \
    /tmp/wezterm.rpm

COPY container_bin/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

RUN ln -s /usr/bin/host-spawn           /usr/local/bin/distrobox            && \
    ln -s /usr/bin/host-spawn           /usr/local/bin/fwupdmgr             && \
    ln -s /usr/bin/host-spawn           /usr/local/bin/podman               && \
    ln -s /usr/bin/host-spawn           /usr/local/bin/rpm-ostree           && \
    ln -s /usr/bin/host-spawn           /usr/local/bin/systemctl            && \
    ln -s /usr/bin/host-spawn           /usr/local/bin/tailscale


# cleanup
RUN dnf clean all