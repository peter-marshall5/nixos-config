{ config, lib, pkgs, ... }:
let
  cfg = config.ab.duckdns;
in
{

  options.ab.duckdns = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
    domains = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
    };
    interface = lib.mkOption {
      default = "br0";
      type = lib.types.str;
    };
    token = lib.mkOption {
      default = ../../secrets/${config.networking.hostName}/duckdns.age;
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {

    age.secrets.duckdns = {
      file = cfg.token;
    };

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

    environment.systemPackages = with pkgs; [ iproute2 iputils curl ];

    systemd.services."ddns" = {
      script = ''
        PATH="${pkgs.iproute2}/bin:${pkgs.curl}/bin:${pkgs.iputils}/bin:$PATH"

        IFACE="${cfg.interface}"
        DOMAINS="${lib.strings.concatStringsSep "," cfg.domains}"
        TOKEN="${config.age.secrets.duckdns.path}"

        ip6=$(
          ip -6 addr show dev $IFACE scope global |
          grep inet6 |
          cut -d' ' -f6 | cut -d'/' -f1 |
          grep -v '^f' |
          head -n 1
        )

        [ "$ip6" == "" ] && exit 1

        # Required to let the router know our new IPv6 address
        ping -q -c 4 -I "$ip6" ff02::2%"$IFACE"

        # Update our DuckDNS record
        response=$(curl -s "https://www.duckdns.org/update?domains=$DOMAINS&token=$(cat $TOKEN)&ip=&ipv6=$ip6")
        [ "$response" == "OK" ] || exit 1
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
