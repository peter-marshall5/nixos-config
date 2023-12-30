{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  inputs.agenix.url = "github:ryantm/agenix";
  outputs = { self, nixpkgs, agenix }: {
    nixosConfigurations.petms = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        agenix.nixosModules.default
        {
          environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
        }
      ];
    };
  };
}
