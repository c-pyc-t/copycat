# flake.nix
#
# description: flake.nix file
# @drgn
# Flakes is a feature of managing Nix packages to simplify usability and improve reproducibility of Nix installations. Flakes manages dependencies between Nix expressions, which are the primary protocols for specifying packages. Flakes implements these protocols in a consistent schema with a common set of policies for managing packages.
#   https://nixos.wiki/wiki/Flakes
#
# flakes let you modulate and create seperate configs more easily
# this was going to be the 'copycat' configuration but a default is required.
# for now, this is the default
# 
{
  description = "NixOS config";
     
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs,... }@inputs: {
    nixosConfigurations = {

      lapcat = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs; };
        modules = [
          # all this should be automagically generated/handled for us, if we update the config we need to truck these around.
          ./local_origin/host/lapcat/hardware-configuration.nix
          inputs.disko.nixosModules.default
          ./local_origin/host/lapcat/disk-device.nix
          ./local_origin/host/lapcat/configuration.nix  # this is where we put our hostname to keep it out of the general configuration, while keeping everything that needs to stay off git off git.

          ./default.nix
        ];

      };

    };
  };

}
