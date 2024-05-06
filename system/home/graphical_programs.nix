{ pkgs

# Note, this should be "the standard library" + HM extensions.
, lib

# Whether to enable module type checking.
, check ? true

  # If disabled, the pkgs attribute passed to this function is used instead.
, useNixpkgsModule ? true }:

with lib;

let

  modules = [
    (pkgs.path + "/nixos/modules/misc/assertions.nix")
    (pkgs.path + "/nixos/modules/misc/meta.nix")

    (mkRemovedOptionModule [ "services" "password-store-sync" ] ''
      Use services.git-sync instead.
    '')
    (mkRemovedOptionModule [ "services" "keepassx" ] ''
      KeePassX is no longer maintained.
    '')
  ] ++ optional useNixpkgsModule ./misc/nixpkgs.nix
    ++ optional (!useNixpkgsModule) ./misc/nixpkgs-disabled.nix;

  pkgsModule = { config, ... }: {
    config = {
      _module.args.baseModules = modules;
      _module.args.pkgsPath = lib.mkDefault
        (if versionAtLeast config.home.stateVersion "20.09" then
          pkgs.path
        else
          <nixpkgs>);
      _module.args.pkgs = lib.mkDefault pkgs;
      _module.check = check;
      lib = lib.hm;
    } // optionalAttrs useNixpkgsModule {
      nixpkgs.system = mkDefault pkgs.stdenv.hostPlatform.system;
    };
  };

in modules ++ [ pkgsModule ]
