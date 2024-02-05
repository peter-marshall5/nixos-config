{ config, lib, pkgs, ... }:
let

  cfg = config.ab.net.upnp;

  redirectArgs = with config.networking.firewall; let
    TCPArgs = map (p: "${toString p} TCP") allowedTCPPorts;
    UDPArgs = map (p: "${toString p} UDP") allowedUDPPorts;
  in builtins.concatStringsSep " " (TCPArgs ++ UDPArgs);

in {

  options.ab.net.upnp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
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

  };

}
