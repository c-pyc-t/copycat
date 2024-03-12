#!/bin/bash


pushd /copycat
git config core.sshCommand "ssh -i /copycat/keys/ssh.key -o \"StrictHostKeyChecking accept-new\""
git config user.name "c-pyc-at"
git config user.email "copycat@imp.nz"
git remote set-url origin "git@github.com:nice-0/copycat.git"

M_ID=$(cat /etc/machine-id)
ACTIVE_CONF=$(cat .active)
BRANCH="copycat#${ACTIVE_CONF}@${M_ID}"

git branch "$BRANCH" 2>/dev/null
set -e 
git checkout "$BRANCH"

GENS=$(nixos-rebuild list-generations)
G_HEAD=$(nixos-rebuild list-generations | head -n 1)
GEN=$(nixos-rebuild list-generations | grep current)

git commit --allow-empty -am "$BRANCH

$G_HEAD
$GEN

.mew"

git push --set-upstream origin "$BRANCH"

git checkout main
