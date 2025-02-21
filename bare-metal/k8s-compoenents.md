Considering HAProxy IP is **172.16.0.29**

---

## HAProxy Configuration (`/etc/haproxy/haproxy.cfg`)

```text
global
    log /dev/log local0
    log /dev/log local1 notice
    maxconn 4096
    daemon

defaults
    log global
    mode tcp
    option tcplog
    timeout connect 10s
    timeout client 1m
    timeout server 1m

frontend kubernetes-api
    bind 0.0.0.0:6443
    mode tcp
    option tcplog
    default_backend k8s-masters

backend k8s-masters
    balance roundrobin
    option tcp-check
    server k8smaster1 172.16.0.19:6443 check
    server k8smaster2 172.16.0.49:6443 check
```

## Multimaster node k8s initialization

---
```
sudo kubeadm init --control-plane-endpoint "172.16.0.29:6443" --upload-certs --pod-network-cidr=10.244.0.0/16
```

## In case of reinitiliaze any node
---

```
sudo rm -rf /etc/cni/
sudo rm -rf /var/lib/etcd/
sudo rm -rf /etc/kubernetes/
sudo rm -rf ~/.kube/
```

## In case of container networking conflict

---

```
ip addr show cni0
sudo ip link delete cni0
sudo systemctl restart containerd.service
```
