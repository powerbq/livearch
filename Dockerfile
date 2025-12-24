FROM alpine AS init
WORKDIR /usr/local/src/build
COPY download.sh archlinux-bootstrap-*-x86_64.tar.zst archlinux-bootstrap-*-x86_64.tar.zst.sha256sum .
RUN apk add --no-cache zstd
RUN ./download.sh \
	&& zstd -dck archlinux-bootstrap-*-x86_64.tar.zst | tar -xp -f - -C / \
	&& rm *.tar.zst *.tar.zst.sha256sum \
	&& rm download.sh

FROM scratch
COPY --from=init /root.x86_64/ /
RUN pacman-key --init \
	&& pacman-key --populate archlinux \
	&& sed -i -r 's|^#(Server = https://mirrors.kernel.org/)|\1|' /etc/pacman.d/mirrorlist \
	&& sed -i -r -z 's|\n#([[]multilib[]])\n#|\n\1\n|' /etc/pacman.conf \
	&& sed -i -r 's|^(CheckSpace)$|DisableSandbox|' /etc/pacman.conf
WORKDIR /usr/local/src/build
COPY aur/ aur/
COPY opt/ opt/
COPY patch/ patch/
COPY PKGBUILD-* boot.sh cleanup.sh custom.sh entrypoint.sh mirror.sh packages.sh save.sh excludes.txt .
COPY boot/init /usr/share/livearch/init
COPY boot/install /usr/lib/initcpio/install/livearch
COPY boot/runscript /usr/lib/initcpio/hooks/livearch
COPY boot/hook.preset /etc/mkinitcpio.d/linux.preset

ENTRYPOINT ["./entrypoint.sh"]

ENV LC_ALL=C
ENV PACMAN_DISABLE_LANDLOCK=1
ENV MIRROR_COUNTRY_CODE=
ENV AUR_PACKAGES=
ENV BOOT_SKIP_HOOKS=
ENV BOOT_ADD_HOOKS=
ENV BOOT_PLYMOUTH_THEME=
ENV PLYMOUTH_INSTALL=yes
ENV FILENAME_SUFFIX=latest
ENV SQUASHFS_BLOCK_SIZE=128K
ENV SQUASHFS_COMP=zstd
ENV SQUASHFS_ADDITIONAL_OPTIONS=
