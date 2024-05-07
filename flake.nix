# flake.nix
#
# description: flake.nix file
# @drgn
#   https://nixos.wiki/wiki/Flakes

{
  description = "copycat";
    inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # i need to swap this back to nixos-23.11 from nixos-unstable once i figure out how to separate plasma/kde
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # FIXME replace with your hostname
      lapcat = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./host/lapcat/default.nix
	  ./host/default.nix
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      # FIXME replace with your username@hostname
      "drgn@lapcat" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main home-manager configuration file <
          ./home-manager/drgn.nix
        ];
      };
    };
  };
}


#{
#  description = "copycat";
#     
#  inputs = {
#    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#
#    disko = {
#      url = "github:nix-community/disko";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#
#    home-manager = {
#      url = "github:nix-community/home-manager";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#  };
#
#  outputs = { nixpkgs, ... }@inputs: {
#    nixosConfigurations.lapcat = nixpkgs.lib.nixosSystem {
#      specialArgs = { inherit inputs; };
#      modules = [
#        inputs.disko.nixosModules.default
#        ./host/lapcat/disk-device.nix
#        ./host/lapcat/hardware-configuration.nix
#        ./host/lapcat/configuration.nix
#        ./default.nix # temp - change to system configuration?
#	./modules-nixos
#	./modules-homemanager
#      ];
#    };
#
#    homeManagerModules.default = ./modules-homemanager;
#  };
#}
