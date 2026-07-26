#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/error.sh"
source "${ROOT_DIR}/scripts/lib/env.sh"

load_dotenv

SIYUAN_WORKSPACE_PATH="${SIYUAN_WORKSPACE_PATH:-/srv/samba/siyuan-workspace}"
SAMBA_SHARE_NAME="${SAMBA_SHARE_NAME:-siyuan-workspace}"
SAMBA_VALID_GROUP="${SAMBA_VALID_GROUP:-siyuan-users}"

log_info "Configuring Samba share for the SiYuan workspace"

if [[ ! -f /etc/samba/smb.conf ]]; then
  abort "Samba is not installed. Run the desktop node's Samba setup first (scripts/install/install_samba.sh + scripts/configure/configure_samba_shares.sh)."
fi

groupadd -f "${SAMBA_VALID_GROUP}"

if ! grep -q "\[${SAMBA_SHARE_NAME}\]" /etc/samba/smb.conf; then

cat <<EOF | tee -a /etc/samba/smb.conf

########################################################################
# SiYuan Workspace Share
########################################################################

[${SAMBA_SHARE_NAME}]
   path = ${SIYUAN_WORKSPACE_PATH}
   browseable = yes
   writable = yes
   guest ok = no
   read only = no
   valid users = @${SAMBA_VALID_GROUP}
   create mask = 0664
   directory mask = 0775
EOF

else
  log_info "Samba share [${SAMBA_SHARE_NAME}] already present in smb.conf — skipping."
fi

systemctl restart smbd

log_info "Samba share configured: //<server>/${SAMBA_SHARE_NAME} -> ${SIYUAN_WORKSPACE_PATH}"
log_warn "This share is for backup/inspection only. SiYuan stores notes as .sy JSON block files, not plain .md, and isn't designed for concurrent writers — stop the siyuan container before editing files directly over SMB."
log_info "Add a user: usermod -aG ${SAMBA_VALID_GROUP} <username> && smbpasswd -a <username>"
