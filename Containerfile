FROM archlinux:base-devel-multilib
COPY repo /tmp/repo
RUN repo-add /tmp/repo/chos.db.tar.gz /tmp/repo/*.pkg.* && \
    echo -e "keyserver-options auto-key-retrieve" >> /etc/pacman.d/gnupg/gpg.conf && \
    # Set yesterday archive to have 'fixed version'
    echo "Server=https://archive.archlinux.org/repos/$(date -d 'yesterday' +%Y/%m/%d)/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist && \
    # Add custom repo
    sed -i '/^\[core\]/s/^/\[chos\]\nSigLevel = Optional TrustAll\nServer = file:\/\/\/tmp\/repo\n\n/' /etc/pacman.conf && \
    # Up/Downgrade and install arch-install-scripts
    pacman --noconfirm -Syyuu arch-install-scripts

