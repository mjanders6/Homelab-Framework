#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

ROLE="default"
VERSION="$(cat "${ROOT_DIR}/VERSION")"
OUTPUT_ROOT="${ROOT_DIR}/images"
BASE_IMAGE_SOURCE="${HOMELAB_BASE_IMAGE_SOURCE:-https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img}"
CHECKSUM_FILE="${HOMELAB_CHECKSUM_FILE:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-root)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --output-root" >&2
        exit 1
      fi
      OUTPUT_ROOT="$2"
      shift 2
      ;;
    --base-image-source)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --base-image-source" >&2
        exit 1
      fi
      BASE_IMAGE_SOURCE="$2"
      shift 2
      ;;
    --checksum-file)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --checksum-file" >&2
        exit 1
      fi
      CHECKSUM_FILE="$2"
      shift 2
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [[ -z "${ROLE_SET:-}" ]]; then
        ROLE="$1"
        ROLE_SET=1
      elif [[ -z "${VERSION_SET:-}" ]]; then
        VERSION="$1"
        VERSION_SET=1
      else
        echo "Unexpected argument: $1" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

ROLE_IMAGE_MAP_SCRIPT="${ROOT_DIR}/scripts/rebuild/role-image-map.sh"
IMAGE_NAME="$(bash "${ROLE_IMAGE_MAP_SCRIPT}" "${ROLE}")"
TARGET_DIR="${OUTPUT_ROOT}/${ROLE}/v${VERSION}"
TARGET_PATH="${TARGET_DIR}/${IMAGE_NAME}-${VERSION}.tar.gz"
MANIFEST_PATH="${TARGET_DIR}/manifest.json"
METADATA_PATH="${TARGET_DIR}/metadata.json"
STAGING_DIR="${TARGET_DIR}/staging"

mkdir -p "${TARGET_DIR}" "${STAGING_DIR}"

if [[ -n "${BASE_IMAGE_SOURCE}" ]]; then
  if [[ -f "${BASE_IMAGE_SOURCE}" ]]; then
    cp "${BASE_IMAGE_SOURCE}" "${STAGING_DIR}/staged-base.img"
  elif [[ "${BASE_IMAGE_SOURCE}" =~ ^https?:// ]]; then
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL "${BASE_IMAGE_SOURCE}" -o "${STAGING_DIR}/staged-base.img"
    elif command -v wget >/dev/null 2>&1; then
      wget -q -O "${STAGING_DIR}/staged-base.img" "${BASE_IMAGE_SOURCE}"
    else
      echo "Neither curl nor wget is available to download the base image" >&2
      exit 1
    fi
  else
    echo "Base image source is not a readable file or URL: ${BASE_IMAGE_SOURCE}" >&2
    exit 1
  fi
else
  echo "No base image source provided; set --base-image-source or HOMELAB_BASE_IMAGE_SOURCE" >&2
  exit 1
fi

if [[ -n "${CHECKSUM_FILE}" ]]; then
  if [[ ! -f "${CHECKSUM_FILE}" ]]; then
    echo "Checksum file not found: ${CHECKSUM_FILE}" >&2
    exit 1
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    ACTUAL_CHECKSUM="$(sha256sum "${STAGING_DIR}/staged-base.img" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    ACTUAL_CHECKSUM="$(shasum -a 256 "${STAGING_DIR}/staged-base.img" | awk '{print $1}')"
  else
    echo "No sha256 utility available for checksum verification" >&2
    exit 1
  fi
  EXPECTED_CHECKSUM="$(tr -d '[:space:]' < "${CHECKSUM_FILE}")"
  if [[ "${ACTUAL_CHECKSUM}" != "${EXPECTED_CHECKSUM}" ]]; then
    echo "Checksum mismatch for ${STAGING_DIR}/staged-base.img" >&2
    exit 1
  fi
fi

cat > "${METADATA_PATH}" <<EOF
{
  "role": "${ROLE}",
  "image_name": "${IMAGE_NAME}",
  "version": "${VERSION}",
  "base_source": "${BASE_IMAGE_SOURCE}",
  "packaged_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

cat > "${MANIFEST_PATH}" <<EOF
{
  "role": "${ROLE}",
  "image_name": "${IMAGE_NAME}",
  "version": "${VERSION}",
  "artifact": "${IMAGE_NAME}-${VERSION}.tar.gz",
  "path": "${TARGET_PATH}",
  "base_source": "${BASE_IMAGE_SOURCE}",
  "checksum_verified": "${CHECKSUM_FILE:+true}"
}
EOF

tar -czf "${TARGET_PATH}" -C "${TARGET_DIR}" staging metadata.json manifest.json

VALIDATION_ROOT="${TARGET_DIR}/validation"
mkdir -p "${VALIDATION_ROOT}"

tar -xzf "${TARGET_PATH}" -C "${VALIDATION_ROOT}"
if [[ ! -f "${VALIDATION_ROOT}/staging/staged-base.img" ]]; then
  echo "Packaged artifact validation failed: staged-base.img missing" >&2
  exit 1
fi
if [[ ! -f "${VALIDATION_ROOT}/manifest.json" ]]; then
  echo "Packaged artifact validation failed: manifest.json missing" >&2
  exit 1
fi
rm -rf "${VALIDATION_ROOT}"

echo "Built image artifact at ${TARGET_PATH}"
echo "Manifest at ${MANIFEST_PATH}"
echo "Validated packaged artifact successfully"
