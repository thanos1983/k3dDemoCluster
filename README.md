# k3dDemoCluster
Simple fundamentals for K3d Cluster all in one with a few minor addons of k8s.

## Content:
- [Prerequisites](#Prerequisites)
- [Pulling and pushing image on local registry](#pulling-and-pushing-image-on-local-registry)
- [Tag the image and push back to registry](#tag-the-image-and-push-back-to-registry)
- [List the images in the registry](#list-the-images-in-the-registry)
- [How to destroy cluster and local registry](#how-to-destroy-cluster-and-local-registry)

## Prerequisites
The user needs to has pre-installed `docker`, `kubectl` and `k3d`. Instalation instructions on how to install [k3d](https://k3d.io/v5.4.6/) and [kubectl](https://kubernetes.io/docs/tasks/tools/).

### Pulling and pushing image on local registry.
We will assume the user has being able succesfully to create the registry.
Next step is to pull the image and push to private registry.

Using a bash terminal:

```bash
$ docker pull nginxinc/nginx-unprivileged:alpine
alpine: Pulling from nginxinc/nginx-unprivileged
8921db27df28: Pull complete
13b32c083c4f: Pull complete
b2627846b2bb: Pull complete
b77ceffd3ccf: Pull complete
7a48156b5afd: Pull complete
8bbbd6e099af: Pull complete
6c96e3e0e9db: Pull complete
f06cd3989bf8: Pull complete
Digest: sha256:a98ca7bc1c302d3823c617a36ed0aeafb3906c4a6b665f77377a655c3dd9a9a8
Status: Downloaded newer image for nginxinc/nginx-unprivileged:alpine
docker.io/nginxinc/nginx-unprivileged:alpine
$ docker image list
REPOSITORY                    TAG            IMAGE ID       CREATED        SIZE
nginxinc/nginx-unprivileged   alpine         dc72302ce1c6   42 hours ago   40.7MB
registry                      2              81c944c2288b   2 months ago   24.1MB
ghcr.io/k3d-io/k3d-proxy      5.4.6          6cb682cd92ed   4 months ago   42.4MB
rancher/k3s                   v1.24.4-k3s1   a32cc5db09d0   4 months ago   214MB
```

### Tag the image and push back to registry.

Using a bash terminal:

```bash
$ docker tag nginxinc/nginx-unprivileged:alpine k3d-registry.localhost:5000/nginx-unp
rivileged:alpine
$ docker push k3d-registry.localhost:5000/nginx-unprivileged:alpine
The push refers to repository [k3d-registry.localhost:5000/nginx-unprivileged]
60869e226b5a: Layer already exists
ad93b67cdc90: Layer already exists
697e0d874f9c: Layer already exists
6c6433b5244a: Layer already exists
b38390e98fc2: Layer already exists
ca72f8533da3: Layer already exists
4b4badaa4f73: Layer already exists
8e012198eea1: Layer already exists
alpine: digest: sha256:b2968c725aab10397452816204cb33da81374f6b229362e6c4eaacbd0dd881ef size: 1989
```

On the example provided above the image already exists but the output will be similar to that.

### List the images in the registry.
Using a bash terminal:

```bash
$ curl -X GET http://k3d-registry.localhost:5000/v2/_catalog
{"repositories":["nginx-unprivileged"]}
```

### How to destroy cluster and local registry
 14 At the end of the experimentation the user can destroy the cluster and registry.
 15
 16 Using a bash terminal:
 17
 18 ```bash
 19 $ ./k3sScripts.sh -d
 20 you have supplied the -d 'destroy' option
 21 INFO[0000] Deleting cluster 'k3s-default'
 22 INFO[0003] Deleting 2 attached volumes...
 23 WARN[0003] Failed to delete volume 'k3d-k3s-default-images' of cluster 'k3s-default': failed to find volume 'k3d-    >  \k3s-default-images': Error: No such volume: k3d-k3s-default-images -> Try to delete it manually
 24 INFO[0003] Removing cluster details from default kubeconfig...
 25 INFO[0003] Removing standalone kubeconfig file (if there is one)...
 26 INFO[0003] Successfully deleted cluster k3s-default!
 27 ```
