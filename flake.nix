{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, nixpkgs, agenix, deploy-rs }: let
    inherit (nixpkgs) lib;
    mkNixosConfig = name: lib.nameValuePair name (nixpkgs.lib.nixosSystem {
      modules = [
        ./modules
        ./modules/profiles/server.nix
        ./cfg/hosts/${name}/configuration.nix
        agenix.nixosModules.default
      ];
      specialArgs = {
        inherit (self) nixosConfigurations;
      };
    });
  in {
    nixosConfigurations = lib.listToAttrs (map mkNixosConfig [ "opcc" ]);

    deploy.nodes.opcc = {
      hostname = self.nixosConfigurations.opcc.config.networking.fqdn;
      remoteBuild = false;
      profiles.system = {
        sshUser = "petms";
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.opcc;
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
