{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    agenix.url = "github:ryantm/agenix";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, nixpkgs, agenix, lanzaboote, home-manager, deploy-rs }: let
    inherit (nixpkgs) lib;
    mkHomeConfig = name: lib.nameValuePair name (home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./cfg/homes/${name}/home.nix ];
      extraSpecialArgs = {
        sshAliases = let
          sshHosts = builtins.filter ({ config, ... }: config.services.openssh.enable)
            (builtins.attrValues self.nixosConfigurations);
        in builtins.listToAttrs (map ({ config, ... }:
          lib.nameValuePair config.networking.hostName {
            hostname = config.networking.fqdnOrHostName;
            port = builtins.head config.services.openssh.ports;
          }
        ) sshHosts);
      };
    });
  in {
    nixosModules.base = ./modules;

    nixosConfigurations = {
      opcc = nixpkgs.lib.nixosSystem {
        modules = [
          self.nixosModules.base
          ./modules/profiles/server.nix
          ./cfg/hosts/opcc/configuration.nix
          agenix.nixosModules.default
        ];
        specialArgs = {
          inherit (self) nixosConfigurations;
        };
      };

      petms = nixpkgs.lib.nixosSystem {
        modules = [
          self.nixosModules.base
          ./modules/profiles/server.nix
          ./cfg/hosts/petms/configuration.nix
        ];
      };

      peter-pc = nixpkgs.lib.nixosSystem {
        modules = [
          self.nixosModules.base
          ./modules/profiles/desktop.nix
          lanzaboote.nixosModules.lanzaboote
          ./modules/profiles/secure-boot.nix
          ./cfg/hosts/peter-pc/configuration.nix
        ];
      };
    };

    homeConfigurations = lib.listToAttrs (map mkHomeConfig [ "petms" "petms@peter-pc" ]);

    deploy.nodes.opcc = {
      hostname = "opcc";
      remoteBuild = false;
      profiles.system = {
        sshUser = "petms";
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.opcc;
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    devShells.x86_64-linux.surface-kernel = let
     pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in (pkgs.callPackage ./modules/hardware/surface-pro-9/kernel {
      baseKernel = pkgs.linux_latest;
    }).overrideAttrs (o: {nativeBuildInputs=o.nativeBuildInputs ++ (with pkgs; [ pkg-config ncurses ]);});
  };
}
