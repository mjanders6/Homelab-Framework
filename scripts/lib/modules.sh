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

declare -A MODULE_DEP_VISITED
declare -A MODULE_DEP_RESOLVED
MODULE_DEP_ORDER=()

resolve_module_dependencies() {
  local module_name="${1:?require module name}"
  if [[ -n "${MODULE_DEP_RESOLVED[${module_name}]:-}" ]]; then
    return 0
  fi
  if [[ -n "${MODULE_DEP_VISITED[${module_name}]:-}" ]]; then
    abort "Dependency cycle detected: ${module_name}"
  fi

  MODULE_DEP_VISITED[${module_name}]=1
  local dependency
  for dependency in $(module_dependencies "${module_name}"); do
    if [[ -n "${dependency}" ]]; then
      resolve_module_dependencies "${dependency}"
    fi
  done

  MODULE_DEP_RESOLVED[${module_name}]=1
  MODULE_DEP_ORDER+=("${module_name}")
}

module_dependency_order() {
  local module_name="${1:?require module name}"
  unset MODULE_DEP_VISITED MODULE_DEP_RESOLVED MODULE_DEP_ORDER
  declare -A MODULE_DEP_VISITED
  declare -A MODULE_DEP_RESOLVED
  MODULE_DEP_ORDER=()

  resolve_module_dependencies "${module_name}"
  printf '%s\n' "${MODULE_DEP_ORDER[@]}"
}

module_diagnostic() {
  local module_name="${1:?require module name}"
  echo "Module diagnostic: ${module_name}"
  echo
  echo "Manifest:"
  module_manifest "${module_name}" || true
  echo
  echo "Resolved dependency order:"
  local module
  local deps
  deps=$(module_dependency_order "${module_name}")
  if [[ -z "${deps}" ]]; then
    echo "  (no dependencies)"
  else
    while IFS= read -r module; do
      echo "  - ${module}"
    done <<<"${deps}"
  fi
  echo
  echo "Lifecycle script status:"
  local action
  for module in ${deps}; do
    echo "  ${module}:"
    for action in $(module_actions); do
      local path="${MODULES_DIR}/${module}/${action}.sh"
      if [[ -f "${path}" ]]; then
        printf '    %-8s %s\n' "${action}" "EXISTS"
      else
        printf '    %-8s %s\n' "${action}" "MISSING"
      fi
    done
  done
}

resolve_module_dependencies() {
  local module_name="${1:?require module name}"
  if [[ -n "${MODULE_DEP_RESOLVED[${module_name}]:-}" ]]; then
    return 0
  fi
  if [[ -n "${MODULE_DEP_VISITED[${module_name}]:-}" ]]; then
    abort "Dependency cycle detected: ${module_name}"
  fi

  MODULE_DEP_VISITED[${module_name}]=1
  local dependency
  for dependency in $(module_dependencies "${module_name}"); do
    if [[ -n "${dependency}" ]]; then
      resolve_module_dependencies "${dependency}"
    fi
  done

  MODULE_DEP_RESOLVED[${module_name}]=1
  MODULE_DEP_ORDER+=("${module_name}")
}

run_module_action() {
  local action="${1:?require action}"
  local module_name="${2:?require module name}"
  local script

  script="$(module_script "${module_name}" "${action}")"
  log_info "Running module ${module_name} action ${action}"
  bash "${script}"
}

run_action_with_dependencies() {
  local action="${1:?require action}"
  local module_name="${2:?require module name}"
  local module

  unset MODULE_DEP_VISITED MODULE_DEP_RESOLVED MODULE_DEP_ORDER
  declare -A MODULE_DEP_VISITED
  declare -A MODULE_DEP_RESOLVED
  MODULE_DEP_ORDER=()

  resolve_module_dependencies "${module_name}"

  for module in "${MODULE_DEP_ORDER[@]}"; do
    log_debug "Resolved dependency order: ${module}"
    run_module_action "${action}" "${module}"
  done
}

run() {
  local action="${1:?require action}"
  local module_name="${2:?require module name}"

  case "${action}" in
    install|configure|verify)
      run_action_with_dependencies "${action}" "${module_name}"
      ;;
    *)
      run_module_action "${action}" "${module_name}"
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    list_modules)
      list_modules
      ;;
    run)
      shift
      run "$@"
      ;;
    deps)
      shift
      module_dependency_order "$@"
      ;;
    diagnose)
      shift
      module_diagnostic "$@"
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
      printf '  deps <module>\n'
      printf '  diagnose <module>\n'
      printf '  module_manifest <module>\n'
      exit 1
      ;;
  esac
fi
