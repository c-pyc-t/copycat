# flake.nix
#
# description: flake.nix file
# @drgn
#   https://nixos.wiki/wiki/Flakes
{
  description = "copycat";
     
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

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations.lapcat = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        inputs.disko.nixosModules.default
        ./host/lapcat/disk-device.nix
        ./host/lapcat/hardware-configuration.nix
        ./host/lapcat/configuration.nix
        ./default.nix # temp - change to system configuration?
#	./nixosModules
      ];
    };

 #   homeManagerModules.default = ./homeManagerModules;
  };
}
