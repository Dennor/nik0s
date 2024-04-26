# Creating new k0s version

* Get SHA and update new `k0s_{ver}.nix`

```
$ ./scripts/get_sum.sh https://github.com/k0sproject/k0s/releases/download/v1.29.4%2Bk0s.0/k0s-v1.29.4+k0s.0-amd64
````

* Update airgap bundle:

```
$ ./scripts/airgap_images $(nix run .#k0s_1_29_4 airgap list-images | tr '\n' ' ')
```

Script depends on `nix-prefetch-docker`, you can just run it in `nix-shell -p`.
