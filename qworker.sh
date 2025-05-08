#!/bin/bash
ssh-keygen -f '/home/jarin/.ssh/known_hosts' -R '10.0.2.200'
cloud-localds --network-config=worker/network-config worker/seed-worker.img worker/user-data worker/meta-data
# uncomment for a fresh restart, or comment if not
cp noble.img noble-worker.img 
qemu-system-x86_64 \
  -nographic \
  -netdev tap,id=n1,ifname=tap1,script=no,downscript=no\
  -device virtio-net-pci,netdev=n1,mac=52:54:00:12:34:57 \
  -machine accel=kvm:tcg \
  -smp 8,sockets=8 -m 8192 -hda noble-worker.img -serial mon:stdio \
  -drive file=worker/seed-worker.img,format=raw
