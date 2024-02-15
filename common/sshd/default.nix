{ config, lib, ... }:
let

  cfg = config.ab.ssh;

in {

  options.ab.ssh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    address = lib.mkOption {
      type = lib.types.str;
      default = config.networking.fqdnOrHostName;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
    };
    upnp.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {

    services.openssh = {
      enable = lib.mkDefault true;

      ports = [ cfg.port ];

      settings.PasswordAuthentication = false;
    };

    ab.net.upnp = lib.mkIf cfg.upnp.enable {
      enable = true;
      openTCPPorts = [ cfg.port ];
    };

  };

}
