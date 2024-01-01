{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    agenix.url = "github:ryantm/agenix";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos.url = "github:nix-community/srvos";
    nixos-appliance.url = "github:peter-marshall5/nixos-appliance";
    nixos-veyron-speedy.url = "github:peter-marshall5/nixos-veyron-speedy";
  };
  outputs = { self, nixpkgs, agenix, microvm, srvos, nixos-appliance, nixos-veyron-speedy }: {
    nixosConfigurations.petms = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        agenix.nixosModules.default
        {
          environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
        }
        microvm.nixosModules.host
        srvos.nixosModules.server
        ./utils/ddns.nix
        ./hosts/petms/configuration.nix
      ];
    };
    nixosConfigurations.peter-chromebook = nixpkgs.lib.nixosSystem {
      system = "armv7l-linux";
      modules = [
        nixos-appliance.nixosModules.appliance-image
        nixos-veyron-speedy.nixosModules.cross-armv7
        nixos-veyron-speedy.nixosModules.veyron-speedy
        ./hosts/peter-chromebook/configuration.nix
      ];
    };
    nixosImages.peter-chromebook = self.nixosConfigurations.peter-chromebook.config.system.build.release;
  };
}
