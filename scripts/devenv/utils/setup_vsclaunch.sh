#!/bin/sh

#############################################
# Setup VS Code launch.json                 #
#############################################
UTL_SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
SCRIPTDIR="${UTL_SCRIPTDIR}/.."
REPO="$1"

VSDIR="${SCRIPTDIR}/../../.vscode"
if [ -f "${VSDIR}/launch_tmpl.json" ] && [ -n "${REPO}" ] ; then
    echo "##############################################"
    echo "# Creating develop environment               #"
    echo "##############################################"

    echo "Generating launch.json ... \c"
    sed -e "s!%%SKAFFOLD_DEFAULT_REPO%%!${REPO}!" "${VSDIR}/launch_tmpl.json" \
            > "${VSDIR}/launch.json"
    echo "Done."
fi
