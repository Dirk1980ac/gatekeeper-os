echo "Deleting zune mesh..."
firewall-cmd --permanent --delete-zone=mesh
echo "Creating zone mesh..."
firewall-cmd --permanent --new-zone=mesh
firewall-cmd --permanent --zone=mesh --add-interface=tun0

echo "Deleting zune public..."
firewall-cmd --permanent --delete-zone=public
echo "Creating zone public..."
firewall-cmd --permanent --new-zone=public
echo "Adding services..."
firewall-cmd --permanent --zone=public --add-service=dhcpv6-client
firewall-cmd --permanent --zone=public --add-service=ssh

echo "Deleting policy int-to-mesh..."
firewall-cmd --permanent --delete-polixy=int-to-mesh
echo "Creating policy int-to-mesh..."
firewall-cmd --permanent --new-polixy=int-to-mesh
echo "Seting ingress-zones..."
firewall-cmd --permanent --policy=int-to-mesh --add-egress-zone=unternal
echo "Setting egress-zones..."
firewall-cmd --permanent --policy=int-to-mesh --add-egress-zone=mesh
echo "Setting target..."
firewall-cmd --permanent --policy=int-to-mesh --set-target=ACCEPT

echo "Deleting policy int-to-pub..."
firewall-cmd --permanent --delete-polixy=int-to-pub
echo "Creating policy int-to-pub..."
firewall-cmd --permanent --new-polixy=int-to-pub
echo "Adding rich Rules..."
echo "Adding ports..."
echo "Adding services..."
echo "Seting ingress-zones..."
firewall-cmd --permanent --policy=int-to-pub --add-egress-zone=internal
echo "Setting egress-zones..."
firewall-cmd --permanent --policy=int-to-pub --add-egress-zone=public
echo "Setting target..."
firewall-cmd --permanent --policy=int-to-pub --set-target=ACCEPT

echo "Deleting policy mesh-to-int..."
firewall-cmd --permanent --delete-polixy=mesh-to-int
echo "Creating policy mesh-to-int..."
firewall-cmd --permanent --new-polixy=mesh-to-int
echo "Seting ingress-zones..."
firewall-cmd --permanent --policy=mesh-to-int --add-egress-zone=mesh
echo "Setting egress-zones..."
firewall-cmd --permanent --policy=mesh-to-int --add-egress-zone=internal
echo "Setting target..."
firewall-cmd --permanent --policy=mesh-to-int --set-target=CONTINUE

echo "Deleting policy public-to-int..."
firewall-cmd --permanent --delete-polixy=public-to-int
echo "Creating policy public-to-int..."
firewall-cmd --permanent --new-polixy=public-to-int
echo "Adding rich Rules..."
echo "Adding ports..."
echo "Adding services..."
echo "Seting ingress-zones..."
firewall-cmd --permanent --policy=public-to-int --add-egress-zone=public
echo "Setting egress-zones..."
firewall-cmd --permanent --policy=public-to-int --add-egress-zone=internal
echo "Setting target..."
firewall-cmd --permanent --policy=public-to-int --set-target=CONTINUE

firewall-cmd --set-default-zone public
firewall-cmd --reload
