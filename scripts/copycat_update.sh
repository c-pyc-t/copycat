#!/bin/bash

pushd /copycat 1 2>/dev/null
sudo git config --add safe.directory /copycat
git config user.name c-pyc-t
git config user.email copycat@imp.nz
git config core.sshCommand "ssh -i /copycat/keys/sys/ssh_system.key"

TIMESTAMP=$(date --rfc-3339=ns)

sudo -u copycat git add -A 
sudo -u copycat git commit -F- <<EOF
$TIMESTAMP
echo hi
EOF
