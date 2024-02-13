{ self, nixpkgs, agenix, lanzaboote, home-manager, installer, ... }:
let

  inherit (nixpkgs) lib;

  pkgs = nixpkgs.legacyPackages.x86_64-linux;

  trustedKeys = import ../lib/ssh-keys.nix "";

  installerPackage = installer.packages.x86_64-linux.default;

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

  mkNixos = name: cfg: lib.nixosSystem {
    inherit (cfg) system;

    modules = [
      agenix.nixosModules.default
      lanzaboote.nixosModules.lanzaboote
      ../modules
      ../hardware/${cfg.hardware}
      {
        ab = cfg; # Abstracted config options
        networking.hostName = lib.mkDefault name;
      }
      systemConfig
    ];

    specialArgs = {
      inherit nixpkgs trustedKeys;
      inherit (self) nixosConfigurations;
      nixosInstaller = (installerPackage + "/iso/nixos.iso");
    };

  };

  mkHome = name:
  lib.nameValuePair name (home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [ ../homes/${name}/home.nix ];
    extraSpecialArgs = {
      sshAliases = let
        sshHosts = builtins.filter (h: h.config.ab.ssh.enable) (builtins.attrValues self.nixosConfigurations);
      in builtins.listToAttrs (map (h:
        lib.nameValuePair h.config.networking.hostName {
          hostname = h.config.ab.ssh.address;
          port = h.config.ab.ssh.port;
        }
      ) sshHosts);
    };
  });

  mkHosts = hosts: lib.mapAttrs mkNixos hosts;

  mkHomes = homes: lib.listToAttrs (map mkHome homes);

}
