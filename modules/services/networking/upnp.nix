{ config, lib, pkgs, ... }:
let

  cfg = config.services.upnpc;

  openPorts = with config.networking.firewall; {
    "TCP" = allowedTCPPorts;
    "UDP" = builtins.filter (p: p != 1900) allowedUDPPorts;
  };

  redirects = builtins.concatLists (lib.mapAttrsToList (
    proto: ports: map (port: "${toString port} ${proto}")
      (builtins.filter (p: p > 1024) ports) # Exclude unpriveleged ports
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
        Type = "exec";
        ExecStart = ''${pkgs.miniupnpc}/bin/upnpc -i -r ${builtins.concatStringsSep " " redirects}'';
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedUDPPorts = [ 1900 ];
      allowedUDPPortRanges = [{ from = 32768; to = 61000; }];
    };

  };

}
