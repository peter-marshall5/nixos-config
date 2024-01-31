{ self, nixpkgs, agenix, lanzaboote, home-manager, installer, ... }:
let

  inherit (nixpkgs) lib;

  pkgs = nixpkgs.legacyPackages.x86_64-linux;

  trustedKeys = import ../ssh-keys.nix "";

in rec {

  systemConfig = { config, ... }: {
    options.ab = {
      system = lib.mkOption {
        type = lib.types.str;
      };
      buildPlatform = lib.mkOption {
        default = "x86_64-linux";
        type = lib.types.str;
      };
      hardware = lib.mkOption {
        type = lib.types.str;
      };
    };
    config = {
      nixpkgs.hostPlatform = config.ab.system;
      nixpkgs.buildPlatform.system = config.ab.buildPlatform;
      nixpkgs.config.allowUnsupportedSystem = true;
      environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
    };
  };

  mkNixos = hostName:
  let
    cfg = import ../hosts/${hostName}/default.nix;
  in lib.nameValuePair hostName (lib.nixosSystem {
    inherit (cfg) system;

    modules = [
      agenix.nixosModules.default
      lanzaboote.nixosModules.lanzaboote
      ../modules
      ../hardware/${cfg.hardware}
      {
        ab = cfg; # Abstracted config options
        networking.hostName = lib.mkDefault hostName;
      }
      systemConfig
    ];

    specialArgs = {
      inherit nixpkgs trustedKeys;
      inherit (self) nixosConfigurations;
      nixosInstaller = (installer + "/iso/nixos.iso");
    };

  });

  mkHome = name:
  lib.nameValuePair name (home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [ ../homes/${name}/home.nix ];
  });

  mkHosts = hostNames: lib.listToAttrs (map mkNixos hostNames);

  mkHomes = homes: lib.listToAttrs (map mkHome homes);

}
