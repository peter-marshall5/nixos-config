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
  outputs = { self, nixpkgs, agenix, microvm, srvos, nixos-appliance, nixos-veyron-speedy }: 
  let
    util = (import ./lib) {
      inherit nixpkgs;
    };
    inherit (util) defineHost;
  in
  {
    nixosConfigurations.petms = defineHost {
      system = "x86_64-linux";
      hostName = "petms";
      isServer = true;
      NICs = ["ens2"];
      extraModules = [
        agenix.nixosModules.default
        {
          environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
        }
        microvm.nixosModules.host
        srvos.nixosModules.server
        ./lib/ddns.nix
      ];
    };
    nixosConfigurations.peter-chromebook = defineHost {
      system = "armv7l-linux";
      hostName = "peter-chromebook";
      isServer = false;
      NICs = ["wlan0"];
      extraModules = [
        nixos-appliance.nixosModules.appliance-image
        nixos-veyron-speedy.nixosModules.cross-armv7
        nixos-veyron-speedy.nixosModules.veyron-speedy
      ];
    };
    nixosImages.peter-chromebook = self.nixosConfigurations.peter-chromebook.config.system.build.release;
  };
}
