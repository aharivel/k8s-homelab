# Makefile

VM_LIST = \
  jumpbox 1 512 10 192.168.122.10 \
  server 1 2048 20 192.168.122.11 \
  node-0 1 2048 20 192.168.122.21 \
  node-1 1 2048 20 192.168.122.22

QCOW2_IMAGE = images/debian-12.qcow2
QCOW2_URL = https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2

create:
	@mkdir -p images vms
	@if [ ! -f "$(QCOW2_IMAGE)" ]; then \
		echo "Downloading Debian 12 image..."; \
		wget -O "$(QCOW2_IMAGE)" "$(QCOW2_URL)"; \
	else \
		echo "Image already exists: $(QCOW2_IMAGE) — skipping download."; \
	fi
	@set -e; set -- $(VM_LIST); \
	while [ $$# -gt 0 ]; do \
		name=$$1; cpu=$$2; mem=$$3; disk=$$4; ip=$$5; \
		echo "Creating $$name..."; \
		./create-vm-libvirt.sh $$name $$cpu $$mem $$disk $$ip; \
		shift 5; \
	done
	@echo "Setting up SSH config..."
	@ln -sf $(PWD)/ssh/config ~/.ssh/config

destroy:
	@for vm in jumpbox server node-0 node-1; do \
		virsh destroy $$vm || true; \
		virsh undefine $$vm --remove-all-storage || true; \
	done
	@rm -rf vms seed

