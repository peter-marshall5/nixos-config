{ config, lib, ... }: let
  cfg = config.virtualisation.networking;
in {

  options.virtualisation.networking = {
    enable = lib.mkEnableOption "bridge networking for VMs / containers";
    uplink = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
    bridge = lib.mkOption {
      default = "virbr0";
      type = lib.types.str;
    };
    address = lib.mkOption {
      default = "10.0.100.1/24";
      type = lib.types.str;
    };
    address6 = lib.mkOption {
      default = "fc00::1/64";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.network.netdevs."20-bridge" = {
      netdevConfig = {
        Name = cfg.bridge;
        Kind = "bridge";
      };
      extraConfig = ''
        [Bridge]
        AgeingTimeSec = 0;
      '';
    };
    systemd.network.networks."20-bridge" = {
      name = cfg.bridge;
      address = [ "${cfg.address}" "${cfg.address6}" ];
    };

    systemd.network.networks."20-bridge-vms" = {
      name = "vb-*";
      bridge = [ cfg.bridge ];
      bridgeConfig.Isolated = true;
    };

    networking.nat = {
      enable = true;
      internalInterfaces = [ cfg.bridge ];
      externalInterface = cfg.uplink;
      enableIPv6 = true;
    };

  };

}
