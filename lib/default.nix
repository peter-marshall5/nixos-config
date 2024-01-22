{ self, nixpkgs, agenix, lanzaboote, ... }:
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
  in lib.attrsets.nameValuePair hostName (lib.nixosSystem {
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
      nixosInstaller = (installerImage + "/image.raw");
    };

  });

  mkHosts = hostNames: builtins.listToAttrs (map mkNixos hostNames);

  installerImage = pkgs.callPackage ../installer {
    inherit nixpkgs trustedKeys;
  };

}
