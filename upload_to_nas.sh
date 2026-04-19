#!/bin/bash

# ==========================================
# Archive MINI-V Android Build Output
# Usage: ./upload_to_nas.sh [DEVICE] [FTP_IP] [USER] [PASS]
# ==========================================

# Argument variables
DEVICE_NAME="${1}"
FTP_IP="${2}"
FTP_USER="${3}"
FTP_PASS="${4}"

# Check arguments
if [ -z "$DEVICE_NAME" ] || [ -z "$FTP_IP" ] || [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ]; then
	echo "Error: unable to parse arguments."
	echo "Usage: $0 [DEVICE_NAME] [FTP_IP] [FTP_USER] [FTP_PASS]"
	exit 1
fi

# Output paths
OUT_DIR="out/target/product/${DEVICE_NAME}"
ZIP_FILE_PATH=$(ls ${OUT_DIR}/lineage-*.zip 2>/dev/null | head -n 1)

# FTP path
FTP_PATH="Jenkins/MINI-V Android/${DEVICE_NAME}"

# Check output file availability
if [ -z "$ZIP_FILE_PATH" ]; then
	echo "Error: output file $ZIP_FILE_PATH not found."
   	exit 1
fi

# Upload with lftp
lftp <<EOF
set ssl:verify-certificate no
set ftp:passive-mode true
open "ftp://${FTP_USER}:${FTP_PASS}@${FTP_IP}"
mkdir -p "${FTP_PATH}"
cd "${FTP_PATH}"
put "${ZIP_FILE_PATH}"
bye
EOF

# Print result message
if [ $? -eq 0 ]; then
	echo "Successfully uploaded $ZIP_FILE_PATH"
else
	echo "Error: failed to upload"
	exit 1
fi
