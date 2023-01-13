# k3dDemoCluster
Simple fundamentals for K3d Cluster all in one with a few minor addons of k8s.

## Content:
- [Prerequisites](#Prerequisites)
- [Pulling and pushing image on local registry](#pulling-and-pushing-image-on-local-registry)
- [Tag the image and push back to registry](#tag-the-image-and-push-back-to-registry)
- [List the images in the registry](#list-the-images-in-the-registry)
- [How to create the registry and k3d cluster](#how-to-create-the-registry-and-k3d-cluster)
- [Deploy to cluster](#deploy-to-cluster)
- [Listing pods for cluster on all namespaces](#listing-pods-for-cluster-on-all-namespaces)
- [Listing the created pods in the specific namespace](#listing-the-created-pods-in-the-specific-namespace)
- [Verify deployment through curl](#verify-deployment-through-curl)
- [List Horizontal Pod Autoscaling on specific namespace](#list-horizontal-pod-autoscaling-on-specific-namespace)
- [Horizontal autoscaling configuration notes](#horizontal-autoscaling-configuration-notes)
- [Kubernetes labels](#kubernetes-labels)
- [How to destroy cluster and local registry](#how-to-destroy-cluster-and-local-registry)

## Prerequisites
The user needs to has pre-installed `docker`, `kubectl` and `k3d`. Instalation instructions on how to install [k3d](https://k3d.io/v5.4.6/) and [kubectl](https://kubernetes.io/docs/tasks/tools/).

### Pulling and pushing image on local registry.
We will assume the user has being able succesfully to create the registry.
Next step is to pull the image and push to private registry. On this example we used the official unpriviledged nginx image [nginxinc/nginx-unprivileged](https://hub.docker.com/r/nginxinc/nginx-unprivileged).

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
60869e226b5a: Pushed
ad93b67cdc90: Pushed
697e0d874f9c: Pushed
6c6433b5244a: Pushed
b38390e98fc2: Pushed
ca72f8533da3: Pushed
4b4badaa4f73: Pushed
8e012198eea1: Pushed
alpine: digest: sha256:b2968c725aab10397452816204cb33da81374f6b229362e6c4eaacbd0dd881ef size: 1989
```

### List the images in the registry.
Using a bash terminal:

```bash
$ curl -X GET http://k3d-registry.localhost:5000/v2/_catalog
{"repositories":["nginx-unprivileged"]}
```

### How to create the registry and k3d cluster.
Using a bash terminal:

```bash
$ ./k3sScripts.sh -c
you have supplied the -c 'create' option
INFO[0000] Creating node 'k3d-registry.localhost'
INFO[0000] Successfully created registry 'k3d-registry.localhost'
INFO[0000] Starting Node 'k3d-registry.localhost'
INFO[0000] Successfully created registry 'k3d-registry.localhost'
# You can now use the registry like this (example):
# 1. create a new cluster that uses this registry
k3d cluster create --registry-use k3d-registry.localhost:5000

# 2. tag an existing local image to be pushed to the registry
docker tag nginx:latest k3d-registry.localhost:5000/mynginx:v0.1

# 3. push that image to the registry
docker push k3d-registry.localhost:5000/mynginx:v0.1

# 4. run a pod that uses this image
kubectl run mynginx --image k3d-registry.localhost:5000/mynginx:v0.1

INFO[0000] portmapping '8080:80' targets the loadbalancer: defaulting to [servers:*:proxy agents:*:proxy]
INFO[0000] Prep: Network
INFO[0000] Re-using existing network 'k3d-k3s-default' (3183dfeb9fe2b08728292322232bb75781ccaa139824ce5b4beb01a6474db882)
INFO[0000] Created image volume k3d-k3s-default-images
INFO[0000] Starting new tools node...
INFO[0001] Creating node 'k3d-k3s-default-server-0'
INFO[0001] Creating node 'k3d-k3s-default-agent-0'
INFO[0001] Creating node 'k3d-k3s-default-agent-1'
INFO[0001] Creating LoadBalancer 'k3d-k3s-default-serverlb'
INFO[0001] Using the k3d-tools node to gather environment information
INFO[0001] Pulling image 'ghcr.io/k3d-io/k3d-tools:5.4.6'
INFO[0003] Starting Node 'k3d-k3s-default-tools'
INFO[0004] HostIP: using network gateway 172.18.0.1 address
INFO[0004] Starting cluster 'k3s-default'
INFO[0004] Starting servers...
INFO[0004] Starting Node 'k3d-k3s-default-server-0'
INFO[0008] Starting agents...
INFO[0008] Starting Node 'k3d-k3s-default-agent-0'
INFO[0008] Starting Node 'k3d-k3s-default-agent-1'
INFO[0013] Starting helpers...
INFO[0013] Starting Node 'k3d-k3s-default-serverlb'
INFO[0020] Injecting records for hostAliases (incl. host.k3d.internal) and for 5 network members into CoreDNS configmap...
INFO[0023] Cluster 'k3s-default' created successfully!
INFO[0023] You can now use it like this:
kubectl cluster-info
```

### Listing pods for cluster on all namespaces.
Using a bash terminal:
```bash
$ kubectl get pods -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   local-path-provisioner-7b7dc8d6f5-jh4j7   1/1     Running     0          59m
kube-system   coredns-b96499967-rg858                   1/1     Running     0          59m
kube-system   helm-install-traefik-crd-j9sgv            0/1     Completed   0          59m
kube-system   svclb-traefik-c3367b89-lq5fn              2/2     Running     0          58m
kube-system   helm-install-traefik-vb948                0/1     Completed   0          59m
kube-system   svclb-traefik-c3367b89-6c5sk              2/2     Running     0          58m
kube-system   svclb-traefik-c3367b89-l8r4f              2/2     Running     0          58m
kube-system   metrics-server-668d979685-8br68           1/1     Running     0          59m
kube-system   traefik-7cd4fcff68-mksbv                  1/1     Running     0          58m
```

### Deploy to cluster.
Using a bash terminal:
```bash
$ kubectl apply -f ingressNginxDeployment.yaml
namespace/demo created
deployment.apps/nginx-deployment created
horizontalpodautoscaler.autoscaling/nginx-hpa created
service/nginx-service created
ingress.networking.k8s.io/nginx-ingress created
```

### Listing the created pods in the specific namespace.
Using a bash terminal:
```bash
$ kubectl get pods -n demo
NAME                              READY   STATUS    RESTARTS   AGE
nginx-deployment-7f4485f5-rjgvc   1/1     Running   0          3m27s
nginx-deployment-7f4485f5-2z4c6   1/1     Running   0          11s
```

### Verify deployment through curl.
Using a bash terminal:
```bash
$ curl localhost:8080 | xmllint --format -
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615  100   615    0     0   275k      0 --:--:-- --:--:-- --:--:--  300k
<?xml version="1.0"?>
<!DOCTYPE html>
<html>
  <head>
    <title>Welcome to nginx!</title>
    <style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
  </head>
  <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
    <p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>
    <p>
      <em>Thank you for using nginx.</em>
    </p>
  </body>
</html>
```

### List Horizontal Pod Autoscaling on specific namespace.
```bash
$ kubectl get hpa -n demo
NAME        REFERENCE                     TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
nginx-hpa   Deployment/nginx-deployment   91%/60%   1         2         2          10m
```

### Horizontal autoscaling configuration notes.
On this simple demo we have restrigned the resources of the container for demostration autoscaling purposes. **Warning:** Do not use these values on production environment they are only for demonstration purposes.

Sample of configurations from deployment:

```bash
containers:
  - name: nginx
    image: k3d-registry.localhost:5000/nginx-unprivileged:alpine
    securityContext:
      allowPrivilegeEscalation: false
    resources:
      limits:
        memory: 20Mi
        cpu: 200m
      requests:
        cpu: 100m
        memory: 10Mi
```

More information can be found on the official documentation of kubernetes [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).

**Note:** Kubernetes has the ability to set upsacaling and also downscaling configuration parameters. On this example we only set upscaling as we try to keep it as simple as possible. For more information please read the official documentation [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/).

### Kubernetes labels.
According to kubernetes best practices it is recommneded for users to use as many labels as possible on a shared namespaces to avoid mixing configurations or deployments.

Sample of the labels on this example:

```bash
selector:
  matchLabels:
    app.kubernetes.io/version: "0.0.1"
    app.kubernetes.io/name: "nginxLabel"
    app.kubernetes.io/component: "frontend"
    app.kubernetes.io/managed-by: "kubectl"
    app.kubernetes.io/instance: "nginxLabel-dev"
```

More information can be found on the official kubernetes documentation [Recommended Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/).

### How to destroy cluster and local registry.
At the end of the experimentation the user can destroy the cluster and registry.

Using a bash terminal:
```bash
$ ./k3sScripts.sh -d
you have supplied the -d 'destroy' option
INFO[0000] Deleting cluster 'k3s-default'
INFO[0003] Deleting 2 attached volumes...
WARN[0003] Failed to delete volume 'k3d-k3s-default-images' of cluster 'k3s-default': failed to find volume 'k3d-    >  \k3s-default-images': Error: No such volume: k3d-k3s-default-images -> Try to delete it manually
INFO[0003] Removing cluster details from default kubeconfig...
INFO[0003] Removing standalone kubeconfig file (if there is one)...
INFO[0003] Successfully deleted cluster k3s-default!
```
