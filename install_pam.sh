#!/usr/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if ! diff "${SCRIPT_DIR}/etc/pam.d/login" /etc/pam.d/login &> /dev/null; then
  sudo "${merge_cmd[@]}" "${SCRIPT_DIR}/etc/pam.d/login" /etc/pam.d/login
fi

