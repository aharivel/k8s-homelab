VM_LIST = \
  "jumpbox 1 512 10 192.168.122.10" \
  "server 1 2048 20 192.168.122.11" \
  "node-0 1 2048 20 192.168.122.21" \
  "node-1 1 2048 20 192.168.122.22"

create:
	@mkdir -p images vms
	wget -nc -O images/debian-12.qcow2 https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2
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
