#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${ROOT_DIR}/error.sh"
source "${ROOT_DIR}/logging.sh"

install_packages() {
  local packages=("$@")
  if (( ${#packages[@]} == 0 )); then
    abort "install_packages requires at least one package name"
  fi
  apt-get update -y
  apt-get install -y "${packages[@]}"
}

package_installed() {
  local package="${1:?require package}"
  dpkg-query -W -f='${Status}' "${package}" 2>/dev/null | grep -q "install ok installed"
}

ensure_package() {
  local package="${1:?require package}"
  if ! package_installed "${package}"; then
    install_packages "${package}"
  fi
}
