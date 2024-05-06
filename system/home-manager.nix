# home-manager.nix

{ inputs, ... }: {

  # may look a bit different
  home-manager."drgn" = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "drgn" = import ./home.nix;
      modules = [
        ./home.nix
        inputs.self.outputs.homeManagerModules.default
      ];
    };
  };

}
