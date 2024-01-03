{ config, lib, pkgs, ... }:
let
  cfg = config.ab.cloudflare;
in
{

  options.ab.cloudflare = {

    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };

    tunnelId = lib.mkOption {
      default = "";
      type = lib.types.str;
    };

    ingress = lib.mkOption {
      default = {};
      type = lib.types.attrsOf lib.types.str;
    };

    webSSHDomain = lib.mkOption {
      default = "";
      type = lib.types.str;
    };

  };

  config = lib.mkIf cfg.enable {

    age.secrets.cloudflare-tunnel = {

      file = ../../../hosts/${config.networking.hostName}/secrets/cloudflared/${cfg.tunnelId}.json.age;

      owner = config.services.cloudflared.user;
      group = config.services.cloudflared.group;

    };

    services.cloudflared = {
  
      enable = true;

      tunnels = {
        "${cfg.tunnelId}" = {
          credentialsFile = config.age.secrets.cloudflare-tunnel.path;

          ingress = lib.mkMerge [
            (builtins.mapAttrs (name: value: { service = "${value}"; }) cfg.ingress)
            (lib.mkIf (cfg.webSSHDomain != "") { "${cfg.webSSHDomain}" = "ssh://localhost:22"; })
          ];

          default = "http_status:404";
        };
      };

    };

    services.openssh.settings.Macs = [ "hmac-sha2-512" ];
  };
}
