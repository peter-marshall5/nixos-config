{ config, lib, pkgs, ... }: let
  minecraftServer = extraConfig: lib.mkMerge ([{
    config = {
      imports = [ ../../modules/services/minecraft.nix ];
      services.minecraft-bedrock-server = {
        enable = true;
        eula = true;
        openFirewall = true;
      };
      system.stateVersion = "24.05";
    };
    extraFlags = map (syscall: "--system-call-filter=${syscall}") [
      "bpf"
      "@keyring"
    ];
  } extraConfig]);
in {

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

  boot.enableContainers = true;
  virtualisation.networking.enable = true;
  virtualisation.networking.uplink = "br0";

  containers.cheesecraft = minecraftServer {
    localAddress = "10.0.100.10/24";
    localAddress6 = "fc00::10/64";
    privateNetwork = true;
    autoStart = true;
    config = {
      services.minecraft-bedrock-server = {
        serverName = "§k::§r §eCheese§bcraft§f - §aSurvival§r §k::§r ";
        levelName = "Cheesecraft Season 4";
        port = 19132;
      };
    };
  };

  containers.build-battle = minecraftServer {
    localAddress = "10.0.100.11/24";
    localAddress6 = "fc00::11/64";
    privateNetwork = true;
    autoStart = true;
    config = {
      services.minecraft-bedrock-server = {
        serverName = " §k::§r §d§lBuild§r  §c§oBattle §k::§r ";
        levelName = "Build Battle v3";
        port = 19133;
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

  nix.settings.trusted-users = [ "root" "@wheel" ];

  system.stateVersion = "24.05";

}
