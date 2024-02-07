{ lib, pkgs, cfg, tokenPath, getIpv6, ... }:

{

  systemd.timers."ddns" = {
    wantedBy = [ "timers.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "5m";
      Unit = "ddns.service";
    };
  };

  systemd.services."ddns" = {
    script = ''
      DOMAINS="${lib.strings.concatStringsSep "," cfg.domains}"
      TOKEN="${tokenPath}"

      # Update our DuckDNS record
      response=$(${pkgs.curl}/bin/curl -s "https://www.duckdns.org/update?domains=$DOMAINS&token=$(cat $TOKEN)")
      [ "$response" == "OK" ] || exit 1
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  ab.logs.notify.services = lib.mkIf cfg.notifyFailures [ "ddns.service" ];

}
