#!/bin/bash

pushd /copycat 1 2>/dev/null
# sudo git config --add safe.directory /copycat
git config --global --add safe.directory /copycat
git remote set-url origin git@github.com:c-pyc-t/copycat.git
git config user.name c-pyc-t
git config user.email copycat@imp.nz
git config core.sshCommand "ssh -i /static/console/keys/sys/ssh_system.key"

TIMESTAMP=$(date --rfc-3339=ns)

git add -A 
git commit -F- <<EOF
$TIMESTAMP
echo hi
EOF
