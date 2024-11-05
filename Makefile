build-container:
	sudo podman build -t gatekeeper-os:latest .

build-qcow2:
	sudo podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t -v ./config.toml:/config.toml:ro -v ./output:/output -v /var/lib/containers/storage:/var/lib/containers/storage quay.io/centos-bootc/bootc-image-builder:latest --type qcow2 --rootfs ext4 --local localhost/gatekeeper-os:latest

build-raw:
	sudo podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t -v ./config.toml:/config.toml:ro -v ./output:/output -v /var/lib/containers/storage:/var/lib/containers/storage quay.io/centos-bootc/bootc-image-builder:latest --type raw --rootfs ext4 --local localhost/gatekeeper-os:latest

build-iso:
	sudo podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t -v ./config.toml:/config.toml:ro -v ./output:/output -v /var/lib/containers/storage:/var/lib/containers/storage quay.io/centos-bootc/bootc-image-builder:latest --type anaconda-iso --rootfs ext4 --local localhost/gatekeeper-os:latest

run-image:
	qemu-system-x86_64 -M accel=kvm -cpu host -smp 2 -m 4096 -bios /usr/share/OVMF/OVMF_CODE.fd -nographic -snapshot output/qcow2/disk.qcow2

all: build-container build-qcow2 build-raw
