{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, nixpkgs, agenix, deploy-rs }: {
    nixosConfigurations.opcc = nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/opcc/configuration.nix
        ./modules
        ./profiles/server.nix
        agenix.nixosModules.default
        ./hardware/generic-pc.nix
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

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
