#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK_DIR="${ROOT_DIR}/.tmp-image-test"

rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"

printf 'fake ubuntu base image\n' > "${WORK_DIR}/base-image.img"
printf '9b8c6e4c0a5f0f9a4d1f0d4e4c7a2b8f5d5e3b0a4f4a8d8d4b2c5f6a8a0d7c0a1\n' > "${WORK_DIR}/base-image.img.sha256"

bash "${ROOT_DIR}/scripts/images/build-role-image.sh" pi5 2.2.0 --output-root "${WORK_DIR}/images" --base-image-source "${WORK_DIR}/base-image.img" --checksum-file "${WORK_DIR}/base-image.img.sha256"

ARTIFACT="${WORK_DIR}/images/pi5/v2.2.0/ubuntu-24.04-server-arm64-raspi-2.2.0.tar.gz"
MANIFEST="${WORK_DIR}/images/pi5/v2.2.0/manifest.json"
METADATA="${WORK_DIR}/images/pi5/v2.2.0/metadata.json"

if [[ ! -f "${ARTIFACT}" ]]; then
  echo "Expected image artifact was not created: ${ARTIFACT}" >&2
  exit 1
fi

if [[ ! -f "${MANIFEST}" ]]; then
  echo "Expected manifest was not created: ${MANIFEST}" >&2
  exit 1
fi

if [[ ! -f "${METADATA}" ]]; then
  echo "Expected metadata file was not created: ${METADATA}" >&2
  exit 1
fi

if ! tar -tzf "${ARTIFACT}" | grep -q 'staged-base.img'; then
  echo "Expected packaged image content was not found in ${ARTIFACT}" >&2
  exit 1
fi

echo "Image build workflow test passed"
