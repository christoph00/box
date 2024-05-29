ARG base_tag=40
ARG base_image=registry.fedoraproject.org/fedora-toolbox
FROM ${base_image}:${base_tag}

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used by distrobox -i <image-name> <container-name>"


COPY ["vscode.repo", "/etc/yum.repos.d/"]


RUN THORIUM_VER=$(curl -sL https://api.github.com/repos/Alex313031/thorium/releases/latest | jq -r '.assets[] | select(.name? | match(".*_AVX2.rpm$")) | .browser_download_url') \
    curl -sL -o /tmp/thorium.rpm ${THORIUM_VER}

RUN WEZTERM_VER=$(curl -sL https://api.github.com/repos/wez/wezterm/releases/latest | jq -r '.assets[] | select(.name? | match(".*fedora39.x86_64.rpm$")) | .browser_download_url') \
    curl -sL -o /tmp/wezterm.rpm ${WEZTERM_VER}


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
    /tmp/thorium.rpm    \
    /rmp/wezterm.rpm

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