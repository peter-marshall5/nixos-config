{ config, lib, pkgs, ... }:
let

  cfg = config.services.duckdns;

in {

  options.services.duckdns = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
    domains = lib.mkOption {
      default = [ config.networking.hostName ];
      type = lib.types.listOf lib.types.str;
    };
    tokenFile = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.timers."duckdns" = {
      wantedBy = [ "timers.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "5m";
        Unit = "duckdns.service";
      };
    };

    systemd.services."duckdns" = {
      script = ''
        response=$(${pkgs.curl}/bin/curl -s "https://www.duckdns.org/update?domains=$DOMAINS&token=$(cat $TOKEN)")
        [ "$response" == "OK" ] || exit 1
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      environment = {
        DOMAINS = lib.strings.concatStringsSep "," cfg.domains;
        TOKEN = cfg.tokenFile;
      };
    };

  };

}
