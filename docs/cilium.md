# Creating new cilium version

* Get SHA of new version and update new `cilium_{ver}.nix`.

```
$ ./scripts/get_sum.sh https://github.com/cilium/charts/raw/master/cilium-{ver}.tgz
```

* Check if kernel modules need to be patched (`cilium-{ver}.patch`).
* Regenerate airgap bundle. At the moment of writing a list of images is:

```
quay.io/cilium/cilium:v1.15.4
quay.io/cilium/certgen:v0.1.11
quay.io/cilium/hubble-relay:v1.15.4
quay.io/cilium/hubble-ui-backend:v0.13.0
quay.io/cilium/hubble-ui:v0.13.0
quay.io/cilium/cilium-envoy:v1.27.4-21905253931655328edaacf3cd16aeda73bbea2f
quay.io/cilium/cilium-etcd-operator:v2.0.7
quay.io/cilium/operator:v1.15.4
quay.io/cilium/operator-generic:v1.15.4
quay.io/cilium/startup-script:62093c5c233ea914bfa26a10ba41f8780d9b737f
quay.io/cilium/cilium:v1.15.4
quay.io/cilium/clustermesh-apiserver:v1.15.4
docker.io/library/busybox:1.36.1
ghcr.io/spiffe/spire-agent:1.8.5
ghcr.io/spiffe/spire-server:1.8.5
```

You can get a decent, maybe not exhaustive (at the moment of writing `operator-generic` is not in values), list of images by running:
```
$ cat cilium/values.yaml | grep 'repository:\|tag:' | sed 's/^ *//' | sed 's/repository: "//' | sed 's/tag: "//' | sed 's/"$//' > images.txt  
```

Generate sums by running:

```
$ ./scripts/airgap_images $(tr '\n' ' ' < images.txt)
```

Script depends on `nix-prefetch-docker`, you can just run it in `nix-shell -p`.
