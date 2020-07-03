# Env directory
This directory contains environment specific files. You can use this directory to make project wide customization.

## Files/Directory
- env.sh : Base configuration(Memory,Disk size of VM/Istio installation).
- setup_host.sh : Script that will run in VM during installation.
- setup_devenv.sh : Script that will run in Local during installation.
- data : Files in this directory will be transferred in /tmp/initial-data/ of VM before running setup_host.sh.
