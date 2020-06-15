# Kubernetes Development

Kubernetes GoLang development environment that uses,
- [Multipass](https://multipass.run/)([Microk8s](https://microk8s.io/))
- [Skaffold](https://skaffold.dev/)
- [Cloud Code](https://cloud.google.com/code)
- [VS Code Remote-Containers Extensions](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

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

and so on. To run setup script, simply type `sh setup_cluster.sh` in `scripts/setup` directory. This script also shows message like bellow.
Please add `insecure-registries` configuration to the docker setting.
```
Add docker daemon config below and restart docker.
======================================================
{"insecure-registries" : [ "192.168.64.7:32000" ]}
======================================================
Done.
```
(Mac) If you want to specify the IP address of VM, examine /var/db/dhcpd_leases.

## Open in VSCode and Remote-Containers Extension
Open this directory with VSCode with Remote-Containers Extension.Remote container may be created.

<!-- ## Download GoLang extension manually and install.
Currently, Cloud Code extension does not support the new GoLang extension. You should download [old version](https://github.com/microsoft/vscode-go/releases/download/0.14.3/Go-0.14.3.vsix) and install it manually. -->
