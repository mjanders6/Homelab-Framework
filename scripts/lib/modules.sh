#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${ROOT_DIR}/error.sh"
source "${ROOT_DIR}/logging.sh"

MODULES_DIR="${ROOT_DIR}/../modules"

list_modules() {
  find "${MODULES_DIR}" -maxdepth 1 -mindepth 1 -type d | sort | xargs -n1 basename
}

module_manifest() {
  local module_name="${1:?require module name}"
  local manifest="${MODULES_DIR}/${module_name}/module.yml"
  if [[ ! -f "${manifest}" ]]; then
    abort "Module manifest not found: ${manifest}"
  fi
  cat "${manifest}"
}

module_script() {
  local module_name="${1:?require module name}"
  local action="${2:?require action}"
  local path="${MODULES_DIR}/${module_name}/${action}.sh"
  if [[ ! -f "${path}" ]]; then
    abort "Module action script not found: ${path}"
  fi
  if [[ ! -x "${path}" ]]; then
    chmod +x "${path}"
  fi
  echo "${path}"
}

module_actions() {
  printf '%s\n' install configure verify status remove backup restore update upgrade report
}

module_has_action() {
  local module_name="${1:?require module name}"
  local action="${2:?require action}"
  local path="${MODULES_DIR}/${module_name}/${action}.sh"
  [[ -f "${path}" ]]
}

module_dependencies() {
  local module_name="${1:?require module name}"
  module_manifest "${module_name}" | sed -n '/^dependencies:/,/^[^[:space:]]/p' | sed '1d' | sed -E 's/^[[:space:]]*-[[:space:]]*//'
}

run_module_action() {
  local action="${1:?require action}"
  local module_name="${2:?require module name}"
  local script

  script="$(module_script "${module_name}" "${action}")"
  log_info "Running module ${module_name} action ${action}"
  bash "${script}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    list_modules)
      list_modules
      ;;
    run)
      shift
      run_module_action "$@"
      ;;
    module_manifest)
      shift
      module_manifest "$@"
      ;;
    *)
      printf 'Usage: %s <command> [args]\n' "$(basename "$0")"
      printf 'Commands:\n'
      printf '  list_modules\n'
      printf '  run <action> <module>\n'
      printf '  module_manifest <module>\n'
      exit 1
      ;;
  esac
fi
