# flake.nix
#
# description: flake.nix file
# @niceguy
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
  };

	
	# where you see nixosConfiguration.copycat most other examples use 'default'
	# this allows for nixos --flake /mnt/etc/nixos#copycat (or #default in that case)
	# i changed back to default for here 


	
	outputs = {nixpkgs, ...} @ inputs:
  {
		# DEFAULT: # nixos-rebuild switch --flake /copycat#default
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
				(import ./base/_origin-version.nix)
				(import ./base/hardware-configuration.nix)

        inputs.disko.nixosModules.default
        (import ./base/disk-device.nix)

        ./default.nix #default
      ];
    };

		# ADD EXTRA CONFIGURATIONS BELOW - name accordingly!
  };

}
