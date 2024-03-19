{ config, lib, pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "opcc";
  networking.domain = "opcc.tk";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.petms = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = (import ../../ssh/trusted-keys.nix);
    initialPassword = "changeme";
  };

  environment.systemPackages = with pkgs; [
    tcpdump
  ];

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

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.ports = [ 2200 ];

  services.upnpc.enable = true;

  systemd.network.netdevs = {
    "10-bridge" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
      };
    };
  };

  systemd.network.networks = {
    "10-bridge-uplink" = {
      name = "en*";
      bridge = [ "br0" ];
    };
    "10-bridge-lan" = {
      name = "br0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      dhcpV4Config.VendorClassIdentifier = "Linux";
      linkConfig.RequiredForOnline = "routable";
    };
  };

  virtualisation.microvms.enable = true;

  microvms.cheesecraft = {
    macAddress = "86:8f:b3:38:dc:a3";
    localAddress = "10.0.100.10";
    localAddress6 = "fc00::10";
    config = {
      services.minecraft-bedrock-server = {
        enable = true;
        eula = true;
        serverName = "§k::§r §eCheese§bcraft§f - §aSurvival§r §k::§r ";
        levelName = "Cheesecraft Season 4";
        port = 19132;
        openFirewall = true;
      };
    };
  };

  microvms.build-battle = {
    macAddress = "ba:2a:b8:b5:e3:71";
    localAddress = "10.0.100.11";
    localAddress6 = "fc00::11";
    config = {
      services.minecraft-bedrock-server = {
        enable = true;
        eula = true;
        serverName = " §k::§r §d§lBuild§r  §c§oBattle §k::§r ";
        levelName = "Build Battle v3";
        port = 19133;
        openFirewall = true;
      };
    };
  };

  boot.initrd.verbose = false;
  boot.kernelParams = [ "quiet" ];

  services.logind.lidSwitch = "ignore";

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
  '';

  services.logrotate.enable = true;

  system.stateVersion = "24.05";

}
