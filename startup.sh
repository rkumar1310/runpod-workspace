#!/bin/bash

apt update && apt install -y openssh-server
mkdir -p /root/.ssh
chmod 700 /root/.ssh
if [ -n "$PUBLIC_KEY" ]; then
  echo "$PUBLIC_KEY" >> /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
  echo "[✔] PUBLIC_KEY injected into /root/.ssh/authorized_keys"
else
  echo "[!] No PUBLIC_KEY provided — password login only"
fi
service ssh restart

# Setup GitHub PAT if provided
if [ -n "$GITHUB_PAT" ] && [ -n "$GITHUB_USERNAME" ]; then
  echo "https://${GITHUB_USERNAME}:${GITHUB_PAT}@github.com" > /root/.git-credentials
  chmod 600 /root/.git-credentials
  git config --global credential.helper store
  echo "[✔] GitHub credentials configured for ${GITHUB_USERNAME}"
else
  echo "[!] GITHUB_USERNAME or GITHUB_PAT not set — GitHub auth won't work"
fi

# Keep container alive
tail -f /dev/null