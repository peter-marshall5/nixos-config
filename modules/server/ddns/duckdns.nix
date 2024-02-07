{ config, lib, pkgs, ... }:
let

  cfg = config.ab.ddns.duckdns;

  tokenPath = ../../../hosts/${config.networking.hostName}/secrets/${cfg.token};

in {

  options.ab.ddns.duckdns = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
    notifyFailures = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
    domains = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
    };
    token = lib.mkOption {
      default = "duckdns.age";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.duckdns.file = tokenPath;

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
        response=$(${pkgs.curl}/bin/curl -s "https://www.duckdns.org/update?domains=$DOMAINS&token=$(cat $TOKEN)")
        [ "$response" == "OK" ] || exit 1
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      environment = {
        DOMAINS = lib.strings.concatStringsSep "," cfg.domains;
        TOKEN = config.age.secrets.duckdns.path;
      };
    };

    ab.logs.notify.services = lib.mkIf cfg.notifyFailures [ "ddns.service" ];

  };

}
