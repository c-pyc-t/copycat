#!/bin/bash
# new_install.sh
#
# description: install nixos on a new system
# @drgn
#
# usage:
#   remotely: sh <(curl imp.nz)
#   locally: sh .. bin/new_install.sh
#
# NOTES:
#   this is not very dynamic - yet, if i feel the need i'll update it to be so
#   importantly you will need to manually and preemptively handle the file names
#   and device names currently
#
#   ... (hey thats declaritive at least!)
#
set -e

alias psak=$(read -t 5 -n 1 -s -r -p "Press any key to continue")
alias cc=$(
echo "
                                              ╻
      ┏━━━┓ ┏━━━┓ ┏━━━┓ ╻   ╻ ┏━━━┓ ┏━━━┓ ━━━━┫
  d   ┃           ┃   ┃ ┃   ┃ ┃               ┃
  r   ┃     ━━━━━ ┃   ┃ ┃   ┃ ┃     ━━━━━     ┃
  g @ ┃           ┃   ┃ ┃   ┃ ┃               ┃
  n   ┗━━━┛ ┗━━━┛ ┣━━━┛ ┗━━━┫ ┗━━━┛ ┗━━─┦     ╹
                  ┃         ┃
                  ┃         ┃               24.
"
)
clear 
cc
psak
#echo "Do you wish to install this program?"
#select yn in "Yes" "No"; do
#    case $yn in
#        Yes ) make install; break;;
#        No ) exit;;
#    esac
#done
#

[[ ! `whoami` == "root"  ]] && echo "Must be run as root.." && exit 1
clear

echo ""
echo ""
echo ""
echo ""
echo ""
echo "THIS WILL NUKE WHATEVER DEVICE YOU POINT IT AT WITHOUT CHECKS AND SAFETY, YOU HAVE BEEN WARNED"
echo ""
echo ""
echo ""
echo ""
echo ""

psak

QVAR="nvme0n1"
CONTINUE=false
while ( ! $CONTINUE ); do 
	select OCE in "ok" "change" "escape";
	do
		case $OCE in
			ok )			CONTINUE=true; break				;; 
			change )	read -p "value: " VAR				;;
			escape )  exit 1											;;
		esac
	done
done

exit 100
psak
# echo "testing t q f"

# select tqf in "true" "que" "false";
# do
#	 case $tqf in
# 		true ) echo "yea bro"  ;;
# 		false ) echo "nah bro" ;;
# 		que ) echo "wtf?"      ;; 
# 	esac
# done






# echo "Enter your device name [nvme0n1]: "
# #EXISTS=0
#
# #while [[ ! $EXISTS ]]; then
# 	read DISK_DEV
# 	[[ $DISK_DEV == "" ]] && DISK_DEV="nvme0n1";
# 	echo "[/dev/$DISK_DEV] ... is this correct?"
# 	read -n1 -r -p " to confirm [y|enter] : " CHOICE
# 	case $CHOICE in
# 		y|Y|"") echo "" ;;
# 		*) exit 1 ;;
# 	esac
# fi
#

# echo "How much swap? [32GiB]: "
# read SWAP_SIZE
# [[ $SWAP_SIZE == "" ]] && SWAP_SIZE="32GiB";
# echo "[$SWAP_SIZE] ... is this correct?"
# read -n1 -r -p " to confirm [y|enter] : " CHOICE
# case $CHOICE in
#   y|Y|"") echo "" ;;
#   *) exit 1 ;;
# esac
#
# pushd /tmp
# nix-shell -p git --run "git clone https://github.com/nice-0/copycat.git"
# pushd /tmp/copycat/base
#
# sed -i "s/32GiB/$SWAP_SIZE/g" disko.nix
#
# nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/copycat/base/disko.nix --arg device '"/dev/'${DISK_DEV}'"'
#
# pushd /mnt/copycat
# nix-shell -p git --run "git clone https://github.com/nice-0/copycat.git ."
# nixos-generate-config --no-filesystems --root /mnt --dir /mnt/copycat/base
#
# nixos-generate-config --no-filesystems --root /mnt --dir /mnt/etc/nixos # do we just need to build agains files in /mnt/etc/nixos? seems arbitrary...
#
# pushd /mnt/copycat/base
#
# sed -i "s/nvme0n1/$DISK_DEV/g" disk-device.nix
#
# echo "#WARNING: DO NOT TOUCH ./_origin-version.nix UNLESS ABSOLUTELY CERTAIN YOU KNOW WHAT YOU'RE DOING" > _origin-version.nix
# echo "{" >> _origin-version.nix
# cat configuration.nix | grep "system.stateVersion" >> _origin-version.nix
# echo "}" >> _origin-version.nix
#
# pushd /mnt/copycat
# cp *.nix base/*.nix /mnt/etc/nixos
#
# pushd /mnt/etc/nixos
# sed -i 's/\.\/base/./g' *.nix
# nixos-install --flake /mnt/etc/nixos#default
#
# ### 
# # setup keys/secret/password shit
# #
#
# # from vimjoyer
# # generate new key at ~/.config/sops/age/keys.txt
# # nix shell nixpkgs#age age-keygen -o ~/.config/sops/age/keys.txt
#
# # generate new key at ~/.config/sops/age/keys.txt from private ssh key at ~/.ssh/private 
# # nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/private > ~/.config/sops/age/keys.txt
#
# # So it seems we should start from an SSH key that way we have all the necessary tools for our
# # systems key management - in theory i think of this more like a butler going back and forth 
# # fetching the correct things but i can step in to adjust things if needed unlike most other
# # authentication methods where a bunch of unknown shit happens... 
# #
# mkdir -p /mnt/copycat/keys
# pushd /mnt/copycat/keys
#
# ssh-keygen -f ./ssh.key -t ed25519 -b 4096 -N '' -C "copycat@copycat@copycat"
#
# # while possible to just simply generate the age.key from ssh.key, that being deterministic
# # gives me the heebies - i think ill just keep a unique age key for unlocking 'local' or internal-to-me
# # systems.
#
# # SSH -> AGE way [defunct for my purposes]
# # nix --experimental-features "nix-command flakes" run nixpkgs#ssh-to-age -- -private-key -i ./ssh.key > ./age.key
# # nix --experimental-features "nix-command flakes" shell nixpkgs#age -c age-keygen -y ./age.key > ./age.key.pub
#
# # AGE GENERATION
# nix --experimental-features "nix-command flakes" shell nixpkgs#age -c age-keygen -o age.key
#
# echo "# copycat ssh.key.pub" >> /tmp/pubs
# cat ssh.key.pub >> /tmp/pubs
#
# # this prints a public version to stdout (we pipe to termbin because boss)
# echo ""
# echo ""
# echo ""
# echo "-v- generating link ... -v-"
# cat /tmp/pubs | nc termbin.com 9999
# echo "-^- your systems PUBLIC SSH key should be in the link above -^-"
# echo ""
# echo ""
# echo ""
# echo "NOTE: age.key AND the 'public' key shouldn't leave my system "
# echo "      the public age key is to act like a canary."
# echo "			currently it doesn't, but it will give me an optional"
# echo "      extra layer of security should i want to implement it "
# echo "      in the future, and doesn't change the basic functionality"
# echo "      aka win/win ..."
# echo "  @niceguy"
# echo ""
# echo    "Press any key to reboot..."
# read -p "     <C-c>-c-c-to-caaancel" && reboot
#
#
