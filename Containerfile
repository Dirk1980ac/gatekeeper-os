FROM registry.fedoraproject.org/fedora-bootc:41
COPY etc /etc
COPY usr /usr
RUN dnf install -y NetworkManager-tui cockpit mc htop zsh jq yggdrasil radvd greenboot dhcp-server greenboot-default-health-checks firewalld freeipa-client
RUN dnf update -y
RUN dnf clean all
RUN systemctl enable yggdrasil device-init firewalld cockpit.socket
