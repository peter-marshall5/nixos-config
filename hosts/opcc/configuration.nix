{ config, lib, ... }: {

  imports = [
    ../../profiles/server.nix
  ];

  time.timeZone = "America/Toronto";

  console.keyMap = "us";

  networking.hostName = "opcc";
  networking.domain = "duckdns.org";

  services.duckdns.enable = true;

  age.secrets.duckdns.file = ../../secrets/duckdns.age;
  services.duckdns.tokenFile = config.age.secrets.duckdns.path;

  # age.secrets.cloudflare.file = ../../../secrets/cloudflare.age;
  # services.cloudflare-dyndns = {
  #   enable = true;
  #   ipv4 = true;
  #   domains = config.networking.domain;
  #   apiTokenFile = config.age.secrets.cloudflare.path;
  # };

  services.microvms.enable = true;
  services.microvms.vms = {
    minecraft = {
      macAddress = "46:97:3E:CE:14:FB";
      config.worlds = (import ./minecraft-servers.nix);
    };
  };

  services.openssh.ports = [ 2200 ];

  services.upnpc.enable = true;

  boot.initrd.kernelModules = [ "efi_pstore" "efivarfs" ];

  fileSystems."/" = {
    device = "/dev/mapper/root";
    encrypted = {
      enable = true;
      label = "root";
      blkDev = "/dev/md127";
      keyFile = "/sys/firmware/efi/efivars/EncKey-b77c97b7-23f5-406d-b86b-15a9216fd71f";
    };
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/61F4-656B";
    fsType = "vfat";
  };

  system.autoUpgrade.enable = true;

}