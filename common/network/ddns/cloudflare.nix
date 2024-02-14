{ config, lib, pkgs, ... }:
let

  cfg = config.ab.ddns.cloudflare;

  tokenPath = ../../../hosts/${config.networking.hostName}/secrets/${cfg.token};

in {

  options.ab.ddns.cloudflare = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
    domains = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
    };
    token = lib.mkOption {
      default = "cloudflare.age";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.cloudflare-ddns.file = tokenPath;
    services.cloudflare-dyndns = {
      enable = true;
      ipv4 = true;
      domains = cfg.domains;
      apiTokenFile = config.age.secrets.cloudflare-ddns.path;
    };
  };

}
