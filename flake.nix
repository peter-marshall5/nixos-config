{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    agenix.url = "github:ryantm/agenix";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos.url = "github:nix-community/srvos";
    nixos-veyron-speedy.url = "github:peter-marshall5/nixos-veyron-speedy";
  };
  outputs = { self, nixpkgs, agenix, microvm, srvos, nixos-veyron-speedy }: 
  let
    util = (import ./lib) {
      inherit nixpkgs agenix microvm srvos nixos-veyron-speedy;
    };
    inherit (util) mkHost image;
  in
  {
    nixosConfigurations.peter-pc = mkHost {
      system = "x86_64-linux";
      hostName = "peter-pc";
      isDesktop = true;
      hardware = "surface-pro-9";
      systemConfig = {
        fs.root.uuid = "c131240c-ff03-467c-b518-f5e435ac38a0";
        fs.root.luksUuid = "6d738085-91c8-457d-b3d9-1c507c7ce6f2";
        fs.esp.uuid = "ED65-FF95";
        fs.nixStoreSubvol = false;
      };
    };
    nixosConfigurations.petms = mkHost {
      system = "x86_64-linux";
      hostName = "petms";
      isServer = true;
      hardware = "qemu";
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
    };
    nixosConfigurations.peter-chromebook = mkHost {
      system = "armv7l-linux";
      buildPlatform = "x86_64-linux";
      hostName = "peter-chromebook";
      hardware = "veyron-speedy";
    };
  };
}
