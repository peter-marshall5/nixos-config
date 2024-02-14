{ config, lib, pkgs, ... }:
let

  cfg = config.ab.net.upnp;

  redirectArgs = with config.networking.firewall; let
    TCPArgs = map (p: "${toString p} TCP") cfg.openTCPPorts;
    UDPArgs = map (p: "${toString p} UDP") cfg.openUDPPorts;
  in builtins.concatStringsSep " " (TCPArgs ++ UDPArgs);

in {

  options.ab.net.upnp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    openTCPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [];
    };
    openUDPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services."upnpc" = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''${pkgs.miniupnpc}/bin/upnpc -i -r ${redirectArgs}'';
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedUDPPorts = [ 1900 ];
      allowedUDPPortRanges = [{ from = 32768; to = 61000; }];
    };

  };

}
