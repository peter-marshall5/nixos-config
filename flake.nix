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
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, ... }@inputs: 
  let
    util = (import ./lib) inputs;
    inherit (util) defineHosts;
  in
  defineHosts [{
    hostName = "opcc";
    system = "x86_64-linux";
    isServer = true;
    hardware = "generic";
    systemConfig = {
      fs.root.uuid = "";
      fs.root.luksUuid = "";
      fs.esp.uuid = "";
      #vms = [self.nixosConfigurations.petms];
    };
  } {
    hostName = "peter-pc";
    system = "x86_64-linux";
    isDesktop = true;
    enableSecureBoot = true;
    hardware = "surface-pro-9";
    systemConfig = {
      fs.root.uuid = "c131240c-ff03-467c-b518-f5e435ac38a0";
      fs.root.luksUuid = "6d738085-91c8-457d-b3d9-1c507c7ce6f2";
      fs.esp.uuid = "ED65-FF95";
      fs.nixStoreSubvol = false;
    };
  } {
    hostName = "petms";
    system = "x86_64-linux";
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
  }];
}
