#!/bin/bash

# SPDX-License-Identifier: GPL-2.0

if [ ! -f /var/lib/.init.done ]; then
	# Configure yggdrasil
	# This has to be done on first boot since the private/public key have
	# to be generated for each host.
	/usr/bin/yggdrasil -genconf -json >/etc/yggdrasil.generated.conf

	jq '.Peers = ["tls://ygg.yt:443", "tls://ygg.mkg20001.io:443",' \
		'"tls://vpn.ltha.de:443", "tls://ygg-uplink.thingylabs.io:443",' \
		'"tls://supergay.network:443","tls://[2a03:3b40:fe:ab::1]:993",' \
		'"tls://37.205.14.171:993"]' \
		/etc/yggdrasil.generated.conf >/etc/yggdrasil.conf

	systemctl restart yggdrasil
fi
