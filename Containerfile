FROM archlinux:base
COPY repo/*.pkg.* /tmp/repo
RUN echo -e "keyserver-options auto-key-retrieve" >> /etc/pacman.d/gnupg/gpg.conf && \
    # Set yesterday archive to have 'fixed version'
    echo "Server=https://archive.archlinux.org/repos/$(date -d 'yesterday' +%Y/%m/%d)/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist && \
    # Cannot check space in chroot
    sed -i '/CheckSpace/s/^/#/g' /etc/pacman.conf && \
    pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman --noconfirm -Syyuu && \
    sed -i '/^\[core\]/s/^/\[bouhaa\]\nSiglevel = Optional TrustAll\nServer = file:\/\/\/tmp\/repo\n\n/' /etc/pacman.conf
RUN repo-add ${{ env.REPODIR }}/${{ env.REPONAME }}.db.tar.gz ${{ env.REPODIR }}/*.pkg.*
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd build -G wheel -m