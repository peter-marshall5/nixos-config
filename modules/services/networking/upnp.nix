{ config, lib, pkgs, ... }:
let

  cfg = config.services.upnpc;

  openPorts = with config.networking.firewall; {
    "TCP" = allowedTCPPorts;
    "UDP" = allowedUDPPorts;
  };

  redirects = builtins.concatLists (lib.mapAttrsToList (
    proto: map (port: "${toString port} ${proto}")
  ) openPorts);

in {

  options.services.upnpc = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services."upnpc" = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''${pkgs.miniupnpc}/bin/upnpc -i -r ${builtins.concatStringsSep " " redirects}'';
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedUDPPorts = [ 1900 ];
      allowedUDPPortRanges = [{ from = 32768; to = 61000; }];
    };

  };

}
