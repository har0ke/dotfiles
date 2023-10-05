#!/usr/bin/bash

set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

declare -ar args=("${@}")
source "${SCRIPT_DIR}/common.sh"

./install_packages_arch.sh "${args[@]}"
./install_dotfiles.sh "${args[@]}"
./install_vimplug.sh

if [ "${DEV}" -eq 1 ] && [ "${WORKSTATION}" -eq 1 ]; then
    ./install_code_extensions.sh
fi

