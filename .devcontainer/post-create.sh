#!/usr/bin/env bash
set -euo pipefail

echo "Installing missing system binaries..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends xdg-utils xclip chromium
echo "post-create.sh completed successfully."
