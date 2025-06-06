# What's this
A setup with qemu running k8s on two nodes, DIY way. 
## Why should I use this?
You shouldn't. Unless you want to.
[There](https://microk8s.io/) [are](https://minikube.sigs.k8s.io/docs/) [far](https://kind.sigs.k8s.io/) [simpler](https://www.geeksforgeeks.org/how-to-integrate-podman-with-kubernetes/) [solutions](https://docs.docker.com/desktop/features/kubernetes/) [to](https://devopscube.com/kubernetes-cluster-vagrant/) [this](https://duckduckgo.com/?hps=1&q=install+kubernetes+on+local+machine&atb=v343-1&ia=web).



## Prerequisites
You need an iptables config with forwarding (check `forward.sh`, and `iptables-fil`)
Also you need to create tap-interfaces for each qemu vm, as well as the bridge br0.
### bridges
Something like this added in `netplan`

```yaml
  bridges:
    br0:
      addresses:
        - 10.0.2.1/24
```        
And 
```
sudo ip tuntap add dev tap0 mode tap user $USER
sudo ip tuntap add dev tap1 mode tap user $USER
sudo ip link set tap1 up
sudo ip link set tap0 up
sudo brctl addif br0 tap0
sudo brctl addif br0 tap1
```

### iptables

Something like:
```bash
iptables -t mangle -P PREROUTING ACCEPT
iptables -t mangle -P INPUT ACCEPT
iptables -t mangle -P FORWARD ACCEPT
iptables -t mangle -P OUTPUT ACCEPT
iptables -t mangle -P POSTROUTING ACCEPT
# Set default policies for filter table chains
iptables -t filter -P INPUT ACCEPT
iptables -t filter -P FORWARD DROP
iptables -t filter -P OUTPUT ACCEPT

# Add FORWARD rules
iptables -t filter -A FORWARD -i br0 -o eno1 -j ACCEPT
iptables -t filter -A FORWARD -i eno1 -o br0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -A FORWARD -i br0 -o br0 -j ACCEPT
iptables -t filter -A FORWARD -i br0 -o eno1 -m conntrack --ctstate NEW -j ACCEPT
iptables -t filter -A FORWARD -i br0 -o eno1 -m conntrack --ctstate NEW -j ACCEPT
iptables -t filter -A FORWARD -i eno1 -o br0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -A FORWARD -i br0 -o br0 -j ACCEPT
# Set default policies for nat table chains
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P INPUT ACCEPT
iptables -t nat -P OUTPUT ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

# Add POSTROUTING rule
iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o eno1 -j MASQUERADE
```

(Your mileage, and interface/CIDR-ranges, may vary)

## Image

```bash
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img -O noble.img
qemu-img resize noble.img 30G
```
## user-data
Fix user-data in control/worker (add ssh key/password)

## Running
Start two terminals on the host machine,run `qcontrol.sh` and `qworker.sh`

## WTF?
If in doubt, take a crash course in Norwegian, and read through [some whimsical docs](https://github.com/jarin/yakshave/wiki/1.-What's-He-Building%3F).