# Kubernetes Golang Development Environment Template (and Sample)

Kubernetes GoLang development environment that uses,
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

1. Visual Studio Code

    See [VS Code Site](https://code.visualstudio.com/). Or simply run `brew cask install visual-studio-code`.

1. Docker and Remote-Containers Extension

    See [VS Code Remote-Containers Extensions](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) page.

## Select Cloud Provider you use
You shoud select cloud provider. Open `.devcontainer/devcontainer.json` and edit the line below.
```
"args": { "VARIANT": "golang:1.15-full"}
```
There are some variant you can choose.
- golang:1.15

  Golang SDK and Kubernetes clients only. You can choose this when you use Okteto or MicroK8s.

- golang:1.15-aws

  Golang SDK, Kubernetes clients and AWS CLI.

- golang:1.15-azure

  Golang SDK, Kubernetes clients and Google Cloud SDK.

- golang:1.15-full

  Golang SDK, Kubernetes clients, AWS CLI, Azure CLI and Google Cloud SDK.
  

# Kubernetes Environment
## Okteto
The most convenient way to get Kubernetes runtime environment is [Okteto](https://okteto.com/) although you can use only your own namespae.
Run `setup_okteto.sh` script with `-t [AccessKey]` and your okteto account. This script setup Kubernetes configuration file and launch.json

## AWS EKS and ECR
AWS is the most major cloud provider. Therefore, there are likely to be many opportunities to use EKS and ECR. EKS cluster and ECR repository must already exist。Run `setup_aws.sh` script with `-c [ClusterName]`.  This script setup Kubernetes configuration file and launch.json

## Azure AKS and ACR
*TBD*

## Google GKE and GCR
*TBD*

## MicroK8s
To use [Microk8s](https://microk8s.io/) with Mac, [Multipass](https://multipass.run/) is required. See Multipass Site and install multipass. Or simply run `brew cask install multipass`

### Run setup script
Run setup script. That script will
- Create multipass VM
- Install Microk8s
- Setup Microk8s
- Create configfile in clusterinfo directory
- Create launch.json

and so on. To run setup script, simply type `sh setup_microk8s.sh` in `scripts/devenv` directory. This script also shows message like bellow.
Remember to add `insecure-registries` configuration to the docker setting.
```
Add docker daemon config below and restart docker.
======================================================
{"insecure-registries" : [ "192.168.64.7:32000" ]}
======================================================
Done.
```
(Mac) If you want to specify the IP address of VM, examine /var/db/dhcpd_leases.  
<br>

# Furthermore
### Specifing the Namespace
If you want to specify the namespace to work in, ***Do not specify the namespace with deployment yamls***. If you do, VSCode Cloud Code extension does not seem to cleanup deployments after stopping the run action, and it does not seem to create port-forward to access it. To specify the namespace, ***change default namespace***. You can change the default namespace by kubens like `kubectl ns [namespace]`.  

<br>

### To Use the Other Private Image Registry Repository.
In special cases, you may want to use a private registry. This is the case when your Kubernetes cluster uses the private registry of another cloud provider.

1. Run `setup_private_registry.sh` script with `-r` option. You can rewrite `launch.json`.
1. Run `setup_private_registry.sh` script with `-s`, `-u` and `-p` option. It will create secret for image pulling.
If you use not a default namespace, use additional `-n` option.
1. Login registry server to configure your local `~/.docker/config.json` to run skaffold.

<br>

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

Please note that Cloud Code extension for VSCode does not delete CRDs when stopping and installing Kiali with Istio is deprecated in version 1.7.

