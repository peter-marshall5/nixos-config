{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, nixpkgs, agenix, deploy-rs }: let
    baseSystem = name: extraModules: nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/${name}/configuration.nix
        ./modules
      ] ++ extraModules;
    };
  in {
    nixosConfigurations = {
      opcc = baseSystem "opcc" [
        agenix.nixosModules.default
      ];
    };

    deploy.nodes.opcc = {
      hostname = self.nixosConfigurations.opcc.config.networking.fqdn;
      remoteBuild = false;
      profiles.system = {
        sshUser = "petms";
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.opcc;
      };
    };

    # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
