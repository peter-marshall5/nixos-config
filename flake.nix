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
      inherit nixpkgs agenix microvm srvos nixos-appliance;
    };
    inherit (util) host;
  in
  {
    nixosConfigurations.petms = host.defineHost {
      system = "x86_64-linux";
      hostName = "petms";
      isServer = true;
      hardware.qemu = true;
      NICs = ["ens2"];
      systemConfig = {
        fs.root.uuid = "e347fbee-252a-4420-a636-5ae21e56f8dd";
        fs.home.uuid = "2a1bb819-57fd-4afc-8caa-f5a36b04ac9f";
        fs.home.luksUuid = "6f8aeabf-bc90-4b93-ae89-2fc75fafeabe";
        fs.esp.uuid = "2430-B4AF";
        cloudflare = {
          enable = true;
          tunnelId = "ada56c81-89c9-403b-8d18-c20c39ab973c";
          webSSHDomain = "ssh-petms.opcc.tk";
        };
        duckdns = {
          enable = true;
          domains = [ "petms-opcc" ];
        };
      };
      users = [{
        name = "petms";
        admin = true;
      }];
    };
    nixosConfigurations.peter-chromebook = host.defineHost {
      system = "armv7l-linux";
      hostName = "peter-chromebook";
      appliance = true;
      extraModules = [
        nixos-veyron-speedy.nixosModules.cross-armv7
        nixos-veyron-speedy.nixosModules.veyron-speedy
        {
          osName = "nixos";
          release = "4"; # Bump this on release
          updateUrl = "https://github.com/peter-marshall5/minimal-server/releases/latest/download/";
        }
      ];
      users = [{
        name = "petms";
        admin = true;
        hashedPassword = "$y$j9T$ynNME1rn9EcOPC.fucIXr0$dP4SF/ok3vVyftlGji9TiA//J6TP4xTHS6UCdQ6Tno2";
      }];
    };
    nixosImages.peter-chromebook = self.nixosConfigurations.peter-chromebook.config.system.build.release;
  };
}
