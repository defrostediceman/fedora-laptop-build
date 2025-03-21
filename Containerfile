ARG PLATFORM=linux/arm64
ENV PLATFORM=${PLATFORM}

FROM --platform=${PLATFORM} quay.io/fedora/fedora-silverblue:41

COPY etc etc

RUN mkdir -p /data /var/home /root/.cache/dconf /root/.gnupg || true && \
    #ln -sr /etc/containers/systemd/*.container /usr/lib/bootc/bound-images.d/ && \
    #ln -sr /etc/containers/systemd/*.image /usr/lib/bootc/bound-images.d/ && \
    mkdir -p /var/tmp && chmod -R 1777 /var/tmp


# add third party RPM repo & packages needed to use COPR from DNF5 
RUN dnf5 install --assumeyes --nogpgcheck \
        #https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf5 clean all && rm -rf /var/cache/libdnf5

RUN dnf5 install --assumeyes --skip-unavailable --exclude=rootfiles --skip-broken \
        @core \
        copr \
        dnf5-plugins \
        fwupd \
        git \
        gh \
        vim-enhanced \
        bash-completion \
        bcc-tools \
        wireshark \
        wireshark-cli \
        wireguard-tools \
        screen \
        tcpdump \
        iperf3 \
        nmap \
        socat \
        hping3 \
        arm-image-installer \ 
        xclip \
        fprintd \
        fprintd-pam \
        input-remapper \
        tmux && \
    dnf5 clean all && rm -rf /var/cache/libdnf5

# Gnome extensions
RUN dnf5 install --assumeyes --skip-broken --skip-unavailable \
        gnome-shell-extension-appindicator \
        gnome-shell-extension-dash-to-dock \
        gnome-shell-extension-blur-my-shell \
        gnome-shell-extension-gsconnect \
        gnome-shell-extension-caffeine \
        gnome-shell-extension-fullscreen-to-empty-workspace \
        gnome-shell-extension-workspace-indicator2 \
        gnome-shell-extension-app-indicator \
        gnome-shell-extension-background-logo && \
    dnf5 clean all && rm -rf /var/cache/libdnf5

# container & virtualisation support
RUN dnf5 install --assumeyes --skip-broken --skip-unavailable \
        @container-management \
        @virtualization \
        podman \
        buildah \
        toolbox \
        flatpak \
        flatpak-builder \
        osbuild \
        krun \
        krunvm \
        crun-krun \
        crun-vm \
        crun \
        skopeo && \
    dnf5 clean all && rm -rf /var/cache/libdnf5

# Nvidia driver
#RUN dnf5 install --assumeyes --skip-broken \
#        nvidia-driver \
#        nvidia-container-toolkit && \
#    rm /var/log/*.log /var/lib/dnf5 -rf && \
#    dnf5 clean all

# cockpit install
COPY tmp/cockpit.desktop /usr/share/applications/cockpit.desktop

RUN dnf5 install --assumeyes --skip-broken \
        cockpit \
        cockpit-networkmanager \
        cockpit-files \
        cockpit-podman \
        cockpit-machines \
        cockpit-navigator \
        cockpit-storaged \
        cockpit-selinux \
        cockpit-ostree && \
    dnf5 clean all && rm -rf /var/cache/libdnf5 && \
    chmod +x /usr/share/applications/cockpit.desktop && \
    curl -Lo /usr/local/bin/cockpit.png https://redhatgov.io/workshops/security_containers/images/cockpit.png || { echo "Failed to download cockpit.png"; exit 0; }

# podman-bootc install
RUN dnf5 copr enable -y gmaglione/podman-bootc && \
    dnf5 install --assumeyes --skip-broken podman-bootc && \
    dnf5 clean all && rm -rf /var/cache/libdnf5

# Cursor.ai appimage
COPY tmp/cursor.desktop /usr/share/applications/cursor.desktop

RUN curl -Lo /usr/local/bin/cursor https://downloader.cursor.sh/linux/appImage/x64 && \
    chmod +x /usr/local/bin/cursor /usr/share/applications/cursor.desktop && \
    curl -Lo /usr/local/bin/cursor.png https://custom.typingmind.com/assets/models/cursor.png || { echo "Failed to download cursor.png"; exit 0; }

# gnome unwanted removal
RUN dnf5 remove --assumeyes --exclude="gnome-shell" --exclude="gnome-desktop*" --exclude="gdm" --noautoremove \
        gnome-text-editor \
        gnome-maps \
        gnome-weather \
        gnome-calendar \
        gnome-clocks \
        gnome-contacts \
        simple-scan \
        evince \
        mediawriter \
        yelp \
        #malcontent \ breaks gnome-shell
        abrt* \
        gnome-abrt \
        rhythmbox \
        totem \
        gnome-characters \
        gnome-calculator \
        gnome-tour \
        libreoffice* \
        gnome-connections \
        gnome-font-viewer \
        gnome-system-monitor \
        gnome-remote-desktop \
        gnome-user-docs \
        papers \
        snapshot \
        baobab \
        virt-manager \
        gnome-color-manager \
        gnome-boxes \
        subscription-manager \
        setroubleshoot \
        firefox \
        nano && \
    dnf5 autoremove --assumeyes && \
    dnf5 clean all && rm -rf /var/cache/libdnf5

# gnome config
COPY tmp/gnome-config /usr/local/bin/gnome-config

RUN chmod +x /usr/local/bin/gnome-config

# flatpak installer
COPY tmp/flatpak-installer /usr/local/bin/flatpak-installer

RUN chmod +x /usr/local/bin/flatpak-installer

# nautifilus directory side defaults
COPY tmp/user-dirs.defaults /etc/xdg/user-dirs.defaults

RUN systemctl set-default graphical.target && \
    systemctl enable \
        fstrim.timer \
        cockpit.socket \
        podman.socket \
        podman-auto-update.timer \
        fwupd.service \
        tuned.service && \
    systemctl disable \
        auditd.service && \
    systemctl mask \
        abrtd.service \
        auditd.service

RUN bootc container lint