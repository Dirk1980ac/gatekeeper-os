FROM registry.fedoraproject.org/fedora-bootc:41
COPY etc /etc
COPY usr /usr
RUN dnf update -y && dnf install -y NetworkManager-tui cockpit mc htop zsh jq yggdrasil radvd greenboot dhcp-server greenboot-default-health-checks firewalld freeipa-client && dnf clean all && systemctl enable device-init firewalld cockpit.socket
