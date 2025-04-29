VM_LIST = \
  "jumpbox 1 2048 10 192.168.122.10" \
  "server 1 2048 20 192.168.122.11" \
  "node-0 1 2048 20 192.168.122.21" \
  "node-1 1 2048 20 192.168.122.22"

create:
	@mkdir -p images vms
	if [ ! -f "$QCOW2_IMAGE" ]; then
		echo "Downloading Debian 12 image..."
		wget -O "$QCOW2_IMAGE" https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2
	else
		echo "Image already exists: $QCOW2_IMAGE — skipping download."
	fi
	@for vm in $(VM_LIST); do \
		set -- $$vm; \
		./create-vm-libvirt.sh $$1 $$2 $$3 $$4 $$5; \
	done
	@echo "Setting up SSH config..."
	ln -sf $(PWD)/ssh/config ~/.ssh/config

destroy:
	for vm in jumpbox server node-0 node-1; do \
		virsh destroy $$vm || true; \
		virsh undefine $$vm --remove-all-storage || true; \
	done
	rm -rf vms seed
