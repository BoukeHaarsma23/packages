FROM scratch
COPY mnt /

# The rootfs can't be modified and systemd can't create them implicitly.
# That's why we have to create them as part of the rootfs.
RUN mkdir /efi

# Normal post installation steps.
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
RUN sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
RUN locale-gen
RUN systemctl enable systemd-timesyncd.service