#!/bin/bash
ssh-keygen -f '/home/jarin/.ssh/known_hosts' -R '10.0.2.100'
cloud-localds --network-config=control/network-config control/seed.img control/user-data control/meta-data
# uncomment for a fresh restart
cp noble.img noble-control.img  
qemu-system-x86_64 \
-display none \
-nographic \
-netdev tap,id=n1,ifname=tap0,script=no,downscript=no \
-device virtio-net-pci,netdev=n1,mac=52:54:00:12:34:56 \
-cpu host,migratable=off \
-machine type=q35,accel=kvm \
-smp 8,sockets=8 \
-m 12G -hda noble-control.img -serial mon:stdio \
-drive file=control/seed.img,format=raw
