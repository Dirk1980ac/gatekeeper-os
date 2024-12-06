FROM registry.fedoraproject.org/fedora-bootc:latest
COPY etc /etc
COPY usr /usr
RUN dnf install -y NetworkManager-tui cockpit mc htop zsh jq yggdrasil radvd \
	greenboot dhcp-server greenboot-default-health-checks firewalld freeipa-client && \
	dnf clean all && \
	systemctl enable device-init firewalld cockpit.socket && \
	systemctl enable yggdrasil && \
	firewall-offline-cmd --zone=public --add-service=dhcpv6-client && \
	firewall-offline-cmd --zone=public --add-service=mdns && \
	firewall-offline-cmd --zone=public --add-service=ssh && \
	firewall-offline-cmd --new-zone=mesh && \
	firewall-offline-cmd --zone=mesh --add-interface=tun0 && \
	firewall-offline-cmd --zone=mesh --add-service=ssh && \
	firewall-offline-cmd --new-policy=int-to-pub && \
	firewall-offline-cmd --policy=int-to-pub --add-ingress-zone=internal && \
	firewall-offline-cmd --policy=int-to-pub --add-egress-zone=public && \
	firewall-offline-cmd --policy=int-to-pub --set-target=ACCEPT && \
	firewall-offline-cmd --new-policy=public-to-int && \
	firewall-offline-cmd --policy=public-to-int --add-ingress-zone=public && \
	firewall-offline-cmd --policy=public-to-int --add-egress-zone=FedoraServer && \
	firewall-offline-cmd --policy=public-to-int --set-target=CONTINUE && \
	firewall-offline-cmd --new-policy=int-to-mesh && \
	firewall-offline-cmd --policy=int-to-mesh --add-ingress-zone=internal && \
	firewall-offline-cmd --policy=int-to-mesh --add-egress-zone=mesh && \
	firewall-offline-cmd --policy=int-to-mesh --set-target=ACCEPT && \
	firewall-offline-cmd --new-policy=mesh-to-int && \
	firewall-offline-cmd --policy=mesh-to-int --set-target=CONTINUE
