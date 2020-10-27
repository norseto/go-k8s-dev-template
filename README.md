# Kubernetes Golang Development Environment Template (and Sample)

Kubernetes GoLang development environment that uses,
- [Multipass](https://multipass.run/)([Microk8s](https://microk8s.io/))
- [Skaffold](https://skaffold.dev/)
- [Cloud Code](https://cloud.google.com/code)
- [VS Code Remote-Containers Extensions](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

Other recommended tools are... (Will be installed in remote container)
- [Kustomize](https://github.com/kubernetes-sigs/kustomize) : Some new feature may not include in `kubectl -k` and Skaffold uses it.
- [Krew](https://krew.sigs.k8s.io/) : For easy install kubens,kubectx
- [kubectx, kubens](https://github.com/ahmetb/kubectx) : Switch namespace, context.

# Setup
## Install prerequisites
Install prerequisites bellow.

1. Multipass
    
    See [Multipass Site](https://multipass.run/) and install multipass. Or simply run `brew cask install multipass`

1. Visual Studio Code

    See [VS Code Site](https://code.visualstudio.com/).

1. Docker and Remote-Containers Extension

    See [VS Code Remote-Containers Extensions](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) page. Or simply run `brew cask install visual-studio-code`.

## Run setup script
Run setup script. That script will
- Create multipass VM
- Install Microk8s
- Setup Microk8s
- Create configfile in clusterinfo directory
- Create launch.json

and so on. To run setup script, simply type `sh setup_microk8s.sh` in `scripts/devenv` directory. This script also shows message like bellow.
Please add `insecure-registries` configuration to the docker setting.
```
Add docker daemon config below and restart docker.
======================================================
{"insecure-registries" : [ "192.168.64.7:32000" ]}
======================================================
Done.
```
(Mac) If you want to specify the IP address of VM, examine /var/db/dhcpd_leases.

---
## Open in VSCode and Remote-Containers Extension
Open this directory with VSCode with Remote-Containers Extension.Remote container may be created.

### Run on Kubernetes
`Run on Kubernetes` runs the application on the Microk8s cluster. Even if the debugger on VSCode is enabled, it cannot be debugged because remote debugger server is not installed in the image that will be run with `Run on Kubernetes`.

### Debug on Kubernetes
`Debug on Kubernetes` runs the application on the Microk8s cluster with delve debug server. You can set break points and cluster deployment/service port through forwarded ports by skaffold.

### Specify the Namespace
If you want to specify the namespace to work in, ***Do not specify the namespace with deployment yamls***. If you do, VSCode Cloud Code extension does not seem to cleanup deployments after stopping the run action, and it does not seem to create port-forward to access it. To specify the namespace, ***change default namespace***. You can change the default namespace by kubens like `kubectl ns [namespace]`.

---
## Furthermore
### To Use the Other Private Image Registry Repository.
1. Run `setup_private_registry.sh` script with `-r` option. You can rewrite `launch.json`.
1. Run `setup_private_registry.sh` script with `-s`, `-u` and `-p` option. It will create secret for image pulling.
If you use not a default namespace, use additional `-n` option.
1. Login registry server to configure your local `~/.docker/config.json` to run skaffold.

### To Use Kaniko with the Other Private Image Registry Repository.
If you want to use [kaniko](https://github.com/GoogleContainerTools/kaniko) to build image,
you need more configuration below. When you use kaniko to build image, you don't need docker
in your local machine because remote cluster does.
However, ***you still need to set up ~/.docker/config.json***
(Even if docker CLI is not installed).

1. Run `setup_kaniko.sh` script with `-s`, `-u` and `-p`. It will create the namespace kaniko to run kaniko pod within.
And create auth secret named `registrykey` for the private image registry.

### To Run in the Service Mesh(Istio)
The `setup_microk8s.sh` script installs [Istio](https://istio.io) with `--with-istio` option. You can check service behaviour in the service mesh environment. If istio cannot inject the probes, the service will not start. It is worth checking behaviour in the Istio environment. There is the namespace `mesh` that labeled to envoy sidecar injection. Please use this namespace and `Run on Kubernetes in Mesh` action. Additional port forwardings are

1. 20001 : Kiali console. You can login with admin/kiali.
1. 9080 : Ingress Gateway. You can curl to this port.

Please note that Cloud Code extension for VSCode does not delete CRDs when stopping.

# Using Okteto
If you don't want to use the local Microk8s, you can use [Okteto](https://okteto.com/) although you can use only your own namespae.
Run `setup_okteto.sh` script with `-t [AccessKey]` and your okteto account. This script setup Kubernetes configuration file and launch.json
