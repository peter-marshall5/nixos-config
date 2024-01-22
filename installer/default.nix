{ lib, pkgs
, nixpkgs
, trustedKeys
, ...}:

let

  installSystem = nixpkgs.lib.nixosSystem {
    inherit (pkgs) system;
    modules = [
      ./configuration.nix
    ];
    specialArgs = {
      inherit trustedKeys;
    };
  };

in installSystem.config.system.build.image
