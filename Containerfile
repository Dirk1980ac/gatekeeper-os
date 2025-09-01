FROM quay.io/fedora/fedora-bootc:latest
ENV imagename="bootc-desktop"

# Install basic system
RUN <<END_OF_BLOCK
set -eu

mkdir /var/roothome

dnf -y install dnf5-plugins

dnf -y copr enable neilalexander/yggdrasil-go

dnf -y install  --setopt="install_weak_deps=False" \
	NetworkManager-tui \
	cockpit \
	mc \
	htop \
	zsh \
	jq \
	yggdrasil \
	radvd \
	dhcp-server \
	greenboot \
	dhcp-server \
	greenboot-default-health-checks \
	firewalld \
	freeipa-client

dnf -y clean all
END_OF_BLOCK

# Assume Raspberry PI if building aarch64. At least for now.
RUN <<EORUN
set -eu

if [ "$(arch)" == "aarch64" ]; then
	dnf install -y bcm2711-firmware uboot-images-armv8
	cp -P /usr/share/uboot/rpi_arm64/u-boot.bin /boot/efi/rpi-u-boot.bin
	mkdir -p /usr/lib/bootc-raspi-firmwares
	cp -a /boot/efi/. /usr/lib/bootc-raspi-firmwares/
	dnf remove -y bcm2711-firmware uboot-images-armv8
	mkdir /usr/bin/bootupctl-orig
	mv /usr/bin/bootupctl /usr/bin/bootupctl-orig/
fi
EORUN

# Install local packages (if available).
RUN --mount=type=bind,source=./packages,target=/packages  <<END_OF_BLOCK
set -eu
shopt -s extglob
shopt -s nullglob

for file in /packages/*.@("$(arch)".rpm|noarch.rpm); do
	dnf -y install "$file"
done

END_OF_BLOCK

ARG buildid="unset"
ARG sshkeys=""

# Set Labels
LABEL org.opencontainers.image.vendor="Dirk Gottschalk" \
	org.opencontainers.image.authors="Dirk Gottschalk" \
	org.opencontainers.image.name=${imagename} \
	org.opencontainers.image.version=${buildid} \
	org.opencontainers.image.desciption="A bootc based router image"

# Copy prepared files
COPY --chmod=600 configs/ssh-00-0local.conf /etc/ssh/sshd_config.d/00-0local.conf
COPY --chmod=644 configs/rpm-ostreed.conf /etc/rpm-ostreed.conf
COPY --chmod=644 configs/watchdog.conf /etc/watchdog.conf
COPY --chmod=700 scripts/device-init.sh /usr/bin/device-init.sh
COPY --chmod=700 scripts/bootupctl-shim /usr/bin/bootupctl
COPY --chmod=600 configs/sudoers-wheel /etc/sudoers.d/wheel
COPY --chmod=600 configs/jail-10-sshd.conf /etc/fail2ban/jail.d/10-sshd.conf
COPY --chmod=644 configs/dconf-user /usr/share/dconf/profile/user
COPY --chmod=644 configs/dconf-00-extensions /etc/dconf/db/local.d/00-extensions
COPY --chmod=644 configs/tmpfiles.conf /usr/lib/tmpfiles.d/cardterm.conf
COPY --chmod=644 configs/sysusers-yggdrasil.conf /usr/lib/sysusers.d/yggdrasil.conf
COPY systemd /usr/lib/systemd/system

# Image signature settings
COPY --chmod=644 configs/registries-sigstore.yaml /usr/share/containers/registries.d/sigstore.yaml
COPY --chmod=644 configs/containers-toolbox.conf /etc/containers/toolbox.conf
COPY --chmod=644 configs/containers-policy.json /usr/share/containers/policy.json
COPY --chmod=644 keys /usr/share/containers/keys

# Do some 'abrakadabra' to build the image.
RUN <<END_OF_MAGIC
# Abort on error and when unbound variables are used
set -eu

echo "IMAGE_ID=${buildid}" >>/usr/lib/os-release
echo "IMAGE_VERSION=${imagename}" >>/usr/lib/os-release

# Embed ssh keys for root if provided
if [[ -n "$sshkeys" ]]; then
	mkdir -p /usr/ssh
	echo $sshkeys > /usr/ssh/root.pub
fi

# Enable required services
systemctl enable device-init firewalld cockpit.socket yggdrasil

# Configure Firewall with some defaults
firewall-offline-cmd --zone=public --add-service=dhcpv6-client
firewall-offline-cmd --zone=public --add-service=mdns
firewall-offline-cmd --zone=public --add-service=ssh
firewall-offline-cmd --new-zone=mesh
firewall-offline-cmd --zone=mesh --add-interface=tun0
firewall-offline-cmd --zone=mesh --add-service=ssh
firewall-offline-cmd --new-policy=int-to-pub
firewall-offline-cmd --policy=int-to-pub --add-ingress-zone=internal
firewall-offline-cmd --policy=int-to-pub --add-egress-zone=public
firewall-offline-cmd --policy=int-to-pub --set-target=ACCEPT
firewall-offline-cmd --new-policy=public-to-int
firewall-offline-cmd --policy=public-to-int --add-ingress-zone=public
firewall-offline-cmd --policy=public-to-int --add-egress-zone=internal
firewall-offline-cmd --policy=public-to-int --set-target=CONTINUE
firewall-offline-cmd --new-policy=int-to-mesh
firewall-offline-cmd --policy=int-to-mesh --add-ingress-zone=internal
firewall-offline-cmd --policy=int-to-mesh --add-egress-zone=mesh
firewall-offline-cmd --policy=int-to-mesh --set-target=ACCEPT
firewall-offline-cmd --new-policy=mesh-to-int
firewall-offline-cmd --policy=mesh-to-int --set-target=CONTINUE

rm -rf /var/{cache,log,tmp,spool}/*

END_OF_MAGIC
