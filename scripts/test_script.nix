# note about shebangs
#
#!/usr/bin/env bash
#
# the above is a correct shebang for nixos (i believe)
# but when using writeShellScriptBin this will be generated for us
# this is important to know as a point of distinction, and to make 
# sure we do not inadvertantly add a shebang we don't need.
#
# this screams potential problems down the line so being aware of it
# is pretty important

# a good way of figuring out the correct binaries to use is the following command
#
# nix build nixpkgs#wl-clipboard --print-out-paths --no-link
# 
# this outputs the full /nix/store path of a built pkg allowing us to do something like
#
# exa --tree /nix/store/[hash-here]-wl-clipboard-2.1.0
#
# to get the actual tree structure
#
# this lets us see the actual structure of a pkg and decide how we want to use it
# in our scripts
# 
# baby steps, this is intrinsically cool and important.

{ pkgs }:

pks.writeShellScriptBin "test-script" ''

echo "example script" | ${pkgs.cowsay}/bin/cowsay | ${lolcat}/bin/lolcat

''
