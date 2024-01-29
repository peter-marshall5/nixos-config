{ config, lib, pkgs, ... }:
let

  cfg = config.ab.ddns;

  tokenPath = config.age.secrets.ddns.path;

  getIpv6 = pkgs.writeScript "get-ipv6.sh" ''
    ${pkgs.iproute2}/bin/ip -6 addr show dev "$1" scope global |
    ${pkgs.gnugrep}/bin/grep inet6 |
    ${pkgs.coreutils}/bin/cut -d' ' -f6 | ${pkgs.coreutils}/bin/cut -d'/' -f1 |
    ${pkgs.gnugrep}/bin/grep -v '^f' |
    ${pkgs.coreutils}/bin/head -n 1
  '';

in
{

  options.ab.ddns = {
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
    protocol = lib.mkOption {
      default = "cloudflare";
      type = lib.types.str;
    };
    token = lib.mkOption {
      default = ../../hosts/${config.networking.hostName}/secrets/${cfg.protocol}.age;
      type = lib.types.path;
    };
    ip-discovery.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
    notifyFailures = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      age.secrets.ddns = {
        file = cfg.token;
      };
    }
    (lib.mkIf cfg.ip-discovery.enable {
      systemd.timers."ip-discovery" = {
        wantedBy = [ "timers.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        timerConfig = {
          OnBootSec = "1m";
          OnUnitActiveSec = "5m";
          Unit = "ip-discovery.service";
        };
      };

      systemd.services."ip-discovery" = {
        script = ''
          iface="${cfg.interface}"
          ip6="$(${getIpv6} "$iface")"
          [ "$ip6" == "" ] && exit 1
          ${pkgs.iputils}/bin/ping -q -c 4 -I "$ip6" ff02::2%"$iface"
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    })
    (lib.mkIf (cfg.protocol == "duckdns") ((import ./duckdns.nix) {
      inherit lib pkgs cfg getIpv6 tokenPath;
    }))
    (lib.mkIf (cfg.protocol == "cloudflare") ((import ./cloudflare.nix) {
      inherit lib pkgs cfg tokenPath;
    }))
  ]);
}
