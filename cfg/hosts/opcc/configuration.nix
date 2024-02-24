{ config, lib, nixosConfigurations, ... }: {

  hardware.generic-x86.enable = true;

  time.timeZone = "America/Toronto";

  console.keyMap = "us";

  networking.hostName = "opcc";

  services.duckdns.enable = true;
  networking.domain = "duckdns.org";

  age.secrets.duckdns.file = ../../../secrets/duckdns.age;
  services.duckdns.tokenFile = config.age.secrets.duckdns.path;

  # age.secrets.cloudflare.file = ../../../secrets/cloudflare.age;
  # services.cloudflare-dyndns = {
  #   enable = true;
  #   ipv4 = true;
  #   domains = config.networking.domain;
  #   apiTokenFile = config.age.secrets.cloudflare.path;
  # };

  services.microvms.vms = {
    minecraft = {
      macAddress = "47:97:3E:CE:14:FB";
      config.worlds = (import ./minecraft-servers.nix);
    };
  };

  services.vm-runner.guests = with nixosConfigurations; [
    petms
    # john
  ];

  services.openssh.ports = [ 2200 ];

  services.upnpc.enable = true;

  fileSystems."/" = {
    device = "/dev/mapper/root";
    encrypted = {
      enable = true;
      label = "root";
      blkDev = "/dev/md127p2";
    };
  };

  system.autoUpgrade.enable = true;

}