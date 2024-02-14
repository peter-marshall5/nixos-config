{ config, lib, ... }:
let
  cfg = config.ab.net;
in{

  imports = [
    ./bridge
    ./networkmanager.nix
    ./upnp
    ./ddns
  ];

  options.ab.net = {
    domain = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
  };

  config = {

    networking.domain = lib.mkDefault cfg.domain;

  };

}
