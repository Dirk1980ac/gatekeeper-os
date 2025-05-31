# build from fedore-bootc:latest which represents the latest Fedora release
FROM registry.fedoraproject.org/fedora-bootc:latest

# Build ID to identify the generated image
ARG buildid

# Copy prepared files into the image
COPY etc /etc
COPY usr /usr

# Set some image labels for identification
LABEL org.opencontainers.image.version="$buildid"
LABEL org.opencontainers.image.authors="Dirk Gottschalk"
LABEL org.opencontainers.image.name="Gatekeeper-OS"
LABEL org.opencontainers.image.desciption="A bootc based router image"

# Do some 'abrakadabra' to build the image.
RUN <<END_OF_MAGIC
# Abort on error and when unbound variables are used
set -eu

echo "IMAGE_ID=$org.opencontainers.image.name" >>/usr/lib/os-release
echo "IMAGE_VERSION=$org.opencontainers.image.name" >>/usr/lib/os-release

#Install packages
dnf -y install NetworkManager-tui cockpit mc htop zsh jq yggdrasil radvd \
	dhcp-server greenboot dhcp-server greenboot-default-health-checks \
	firewalld freeipa-client --setopt="install_weak_deps=False"

# Clean up dnf to reduce image size
dnf -y clean all

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
END_OF_MAGIC
