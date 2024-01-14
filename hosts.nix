{...}: {

  opcc = {
    system = "x86_64-linux";
    isServer = true;
    hardware = "generic";
    systemConfig = {
      fs.root.uuid = "f7086f18-40c4-462b-9b79-bcc522a2f6ce";
      fs.root.luksUuid = "388cf94a-5063-41ec-8830-1b62b506fe47";
      fs.home.onRoot = true;
      fs.esp.uuid = "64C1-9B6E";
      #vms = [self.nixosConfigurations.petms];
    };
  };

  peter-pc = {
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
  };
  
  petms = {
    system = "x86_64-linux";
    isServer = true;
    hardware = "virt";
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

}
