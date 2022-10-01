ARG DEBIAN_IMAGE=busybox
ARG UBUNTU_IMAGE=busybox

FROM $DEBIAN_IMAGE AS debian
ENV LC_ALL=C
ENV DEBIAN_FRONTEND=noninteractive
RUN if which apt-get; \
	then \
	apt-get update \
	&& apt-get install -y linux-image-amd64 \
	&& apt-get clean \
	&& tar -zcphf /pkgroot.tar.gz /boot/vmlinuz-* /lib/modules; \
	fi

FROM $UBUNTU_IMAGE AS ubuntu
ENV LC_ALL=C
ENV DEBIAN_FRONTEND=noninteractive
RUN if which apt-get; \
	then \
	apt-get update \
	&& apt-get install -y linux-image-generic \
	&& apt-get clean \
	&& tar -zcphf /pkgroot.tar.gz /boot/vmlinuz-* /lib/modules; \
	fi

FROM archlinux AS bootstrap
ARG MIRROR_COUNTRY_CODE=
ENV LC_ALL=C
WORKDIR /usr/local/src/build
COPY mirror.sh unpack.sh .
RUN pacman -Syu --noconfirm --needed pacman-contrib \
	&& ./mirror.sh \
	&& yes | pacman -Scc
RUN mkdir -p root/var/lib/pacman \
	&& pacman -Syu -r root --dbonly --noconfirm base mkinitcpio python squashfs-tools sudo \
	&& ./unpack.sh \
	&& yes | pacman -Scc
RUN cat /etc/pacman.d/mirrorlist > root/etc/pacman.d/mirrorlist \
	&& sed -i -r -z 's|\n#([[]multilib[]])\n#|\n\1\n|' root/etc/pacman.conf \
	&& sed -i -r 's|^(CheckSpace)$|#\1|' root/etc/pacman.conf
COPY patch/usr/local/sbin/postinst.sh patch/usr/local/sbin/posthooks.py root/usr/local/sbin/

FROM scratch
# FROM scratch AS fresh
ENV LC_ALL=C
WORKDIR /usr/local/src/build
COPY --from=bootstrap /usr/local/src/build/root/ /
RUN /usr/local/sbin/postinst.sh \
	&& /usr/local/sbin/posthooks.py \
	&& rm /usr/local/sbin/postinst.sh \
	&& rm /usr/local/sbin/posthooks.py
RUN pacman-key --init \
	&& pacman-key --populate archlinux

# FROM scratch AS custom
# ARG AUR_PACKAGES=
# ENV LC_ALL=C
# WORKDIR /usr/local/src/build
# COPY --from=fresh / /
COPY --from=debian /pkgroot.tar.gz* kernels/debian/
COPY --from=ubuntu /pkgroot.tar.gz* kernels/ubuntu/
COPY aur/ aur/
COPY custom.sh .
RUN groupadd -g 3219 build \
	&& useradd -u 3219 -g 3219 -m build \
	&& echo 'build ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/build
# RUN su -c './custom.sh' build

# FROM scratch
# ENV LC_ALL=C
# WORKDIR /usr/local/src/build
# COPY --from=fresh / /
COPY PKGBUILD-* boot.sh cleanup.sh packages.sh save.sh system.sh unpack.sh .
COPY opt/ opt/
COPY patch/ patch/
COPY boot/init /usr/share/livearch/init
COPY boot/install /usr/lib/initcpio/install/livearch
COPY boot/runscript /usr/lib/initcpio/hooks/livearch
COPY boot/hook.preset /usr/share/mkinitcpio/hook.preset
# COPY --from=custom /usr/local/src/build/opt/pkg-built/ opt/pkg-built/

ENV AUR_PACKAGES=
ENV BOOT_PACKAGES=linux
ENV BOOT_SKIP_HOOKS=
ENV BOOT_ADD_HOOKS=
ENV BOOT_PLYMOUTH_THEME=
ENV PLYMOUTH_INSTALL=yes
ENV FILENAME_SUFFIX=latest
ENV SQUASHFS_BLOCK_SIZE=128K
ENV SQUASHFS_COMP=zstd
ENV SQUASHFS_ADDITIONAL_OPTIONS=
