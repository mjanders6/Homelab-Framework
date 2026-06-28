#!/usr/bin/env bash

##############################################################################
#
# Home Lab Setup — Configure Samba Shares
#
##############################################################################

set -e

echo "Configuring Samba shares..."

##############################################################################
# Create Shared Directories
##############################################################################

sudo mkdir -p /srv/shares/public
sudo mkdir -p /srv/shares/private

##############################################################################
# Permissions
##############################################################################

sudo chmod -R 2775 /srv/shares/public
sudo chown -R nobody:nogroup /srv/shares/public

sudo chmod -R 2770 /srv/shares/private
sudo chown -R root:root /srv/shares/private

##############################################################################
# Create Samba Group
##############################################################################

sudo groupadd sambashare || true

##############################################################################
# Backup Existing Config
##############################################################################

if [ ! -f /etc/samba/smb.conf.bak ]; then
    sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
fi

##############################################################################
# Avoid Duplicate Share Entries
##############################################################################

if ! grep -q "\[Public\]" /etc/samba/smb.conf; then

cat <<EOF | sudo tee -a /etc/samba/smb.conf

########################################################################
# Public Share
########################################################################

[Public]
   path = /srv/shares/public
   browseable = yes
   writable = yes
   guest ok = yes
   read only = no
   create mask = 0664
   directory mask = 2775

########################################################################
# Private Share
########################################################################

[Private]
   path = /srv/shares/private
   browseable = yes
   writable = yes
   guest ok = no
   read only = no
   valid users = @sambashare
   create mask = 0660
   directory mask = 2770

EOF

fi

##############################################################################
# Restart Samba
##############################################################################

sudo systemctl restart smbd

##############################################################################
# Status
##############################################################################

echo ""
echo "Samba shares configured successfully."
echo ""
echo "Public Share:"
echo "  /srv/shares/public"
echo ""
echo "Private Share:"
echo "  /srv/shares/private"
echo ""
echo "To add Samba users:"
echo "  sudo smbpasswd -a USERNAME"