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
      inherit nixpkgs agenix microvm srvos;
    };
    inherit (util) host modules;
  in
  {
    nixosConfigurations.petms = host.defineHost {
      system = "x86_64-linux";
      hostName = "petms";
      isServer = true;
      NICs = ["ens2"];
      systemConfig = {
        cloudflare = {
          enable = true;
          tunnelId = "ada56c81-89c9-403b-8d18-c20c39ab973c";
          webSSHDomain = "ssh-petms.opcc.tk";
        };
        ddns = {
          enable = true;
          domains = [ "petms-opcc" ];
        };
      };
    };
    nixosConfigurations.peter-chromebook = host.defineHost {
      system = "armv7l-linux";
      hostName = "peter-chromebook";
      isServer = false;
      extraModules = [
        nixos-appliance.nixosModules.appliance-image
        nixos-veyron-speedy.nixosModules.cross-armv7
        nixos-veyron-speedy.nixosModules.veyron-speedy
      ];
    };
    nixosImages.peter-chromebook = self.nixosConfigurations.peter-chromebook.config.system.build.release;
  };
}
