{ config, lib, ... }:
let
  cfg = config.ab.ddns;
in
{

  options = {
    ab.ddns = {
      enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
      };
      domains = lib.mkOption {
        default = [];
        type = lib.types.listOf lib.types.str;
      };
      interface = lib.mkOption {
        default = "eth0";
        type = lib.types.str;
      };
      token = lib.mkOption {
        default = "";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
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
        ip6=$(
          ip -6 addr show dev $IFACE scope global |
          grep inet6 |
          cut -d' ' -f6 | cut -d'/' -f1 |
          grep -v '^f' |
          head -n 1
        )
        if [ "$ip6" != "" ]; then
          # Required to let the router know our new IPv6 address
          ping -q -c 4 -I "$ip6" ff02::2%"$IFACE"

          # Update our DuckDNS record
          curl -s "https://www.duckdns.org/update?domains=$DOMAINS&token=$(cat $TOKEN)&ip=&ipv6=$ip6"
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Environment = [
          "PATH=/run/current-system/sw/bin"
          "IFACE=${cfg.interface}" 
          "DOMAINS=${lib.strings.concatStringsSep "," cfg.domains}"
          "TOKEN=${cfg.token}"
        ];
      };
    };
  };
}
