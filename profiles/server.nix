{ lib, pkgs, ... }: {

  imports = [ ./base.nix ];

  boot.swraid.enable = true;
  fonts.fontconfig.enable = false;
  sound.enable = false;
  environment.noXlibs = true;

  networking = {
    useNetworkd = true;
    nftables.enable = true;
  };

  networking.useDHCP = lib.mkForce true;

  systemd.network = let
    bridge = "br0";
  in {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = [ "en*" "vm-*" ];
      networkConfig = {
        Bridge = bridge;
      };
    };
    networks."10-lan-bridge" = {
      matchConfig.Name = bridge;
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      dhcpV4Config.VendorClassIdentifier = "Linux";
      linkConfig.RequiredForOnline = "routable";
    };
    netdevs."10-bridge" = {
      netdevConfig = {
        Name = bridge;
        Kind = "bridge";
      };
    };
  };

  services.openssh = {
    enable = lib.mkDefault true;

    settings.PasswordAuthentication = false;
  };

  systemd.watchdog = {
    runtimeTime = "20s";
    rebootTime = "30s";
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
  '';

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.package = pkgs.qemu_test;

}