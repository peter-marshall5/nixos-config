{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  inputs.agenix.url = "github:ryantm/agenix";
  inputs.microvm.url = "github:astro/microvm.nix";
  inputs.microvm.inputs.nixpkgs.follows = "nixpkgs";
  inputs.srvos.url = "github:nix-community/srvos";
  inputs.srvos.inputs.nixpkgs.follows = "nixpkgs";
  outputs = { self, nixpkgs, agenix, microvm, srvos }: {
    nixosConfigurations.petms = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        agenix.nixosModules.default
        {
          environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
        }
        microvm.nixosModules.host
        srvos.nixosModules.server
        ./configuration.nix
      ];
    };
  };
}
