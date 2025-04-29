#!/bin/bash
set -e

NAME=$1
CPU=$2
RAM=$3
DISK=$4
IP=$5

mkdir -p vms seed/$NAME

# Set the root password and inject SSH key
LIBGUESTFS_BACKEND=direct virt-customize -a images/debian-12.qcow2 --smp 4 --memsize 8192 \
	--timezone UTC \
	--root-password password:test \
	--ssh-inject "root:file:/home/aharivel/.ssh/id_rsa.pub"

BASE_IMAGE=images/debian-12.qcow2
DISK_IMG="vms/${NAME}.qcow2"
cp "$BASE_IMAGE" "$DISK_IMG"
qemu-img resize "$DISK_IMG" "${DISK}G"

SSH_KEY=$(cat ~/.ssh/id_rsa.pub)

sed -e "s|__HOSTNAME__|$NAME|g" \
    -e "s|__IP__|$IP|g" \
    -e "s|__SSH_KEY__|$SSH_KEY|g" \
    cloud-init/user-data.template > seed/$NAME/user-data

cat > seed/$NAME/meta-data <<EOF
instance-id: $NAME
local-hostname: $NAME
EOF

genisoimage -output seed/$NAME/seed.iso -volid cidata -joliet -rock \
  seed/$NAME/user-data seed/$NAME/meta-data

virt-install \
  --name $NAME \
  --vcpus $CPU \
  --memory $RAM \
  --disk path=$DISK_IMG,format=qcow2 \
  --disk path=seed/$NAME/seed.iso,device=cdrom \
  --os-variant debian12 \
  --import \
  --graphics none \
  --network network=default,model=virtio \
  --noautoconsole

