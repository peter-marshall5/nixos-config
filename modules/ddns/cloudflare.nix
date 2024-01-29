{ lib, pkgs, cfg, tokenPath, ... }:
{

  services.cloudflare-dyndns = {
    enable = true;
    ipv4 = true;
    domains = cfg.domains;
    apiTokenFile = tokenPath;
  };

}
