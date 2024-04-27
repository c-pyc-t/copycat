#!/run/current-system/sw/bin/env /run/current-system/sw/bin/bash

TIMESTAMP=$(date --rfc-3339=ns)

pushd /copycat 1 2>/dev/null
nvim /copycat/cfg/default.nix

nh os switch
if [[ $? -eq 0 ]]; then 
	git add -A
	git commit -F- <<EOF
 copycat

$TIMESTAMP

$(nixos-rebuild --flake /copycat/cfg#copycat list-generations)

    へ
（• ˕ •マ
   ~mew.
EOF
echo end of if 
fi

echo end of script yay


# pushd /copycat 1 2>/dev/null
# 
# git remote set-url origin git@github.com:c-pyc-t/copycat.git
# git config user.name c-pyc-t
# git config user.email copycat@imp.nz
# git config core.sshCommand "ssh -i /static/console/keys/sys/ssh_system.key"
# 
# TIMESTAMP=$(date --rfc-3339=ns)
# 
# git add -A
# git commit -F- <<EOF
# 
#  copycat
# 
# $TIMESTAMP
# 
# $(nixos-rebuild --flake /copycat/cfg#copycat list-generations)
# 
#     へ
# （• ˕ •マ
#    ~mew.
# EOF
