{ config, lib, ... }:
let

  cfg = config.ab.ssh;

in {

  options.ab.ssh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    address = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
    };
  };

  config = lib.mkIf cfg.enable {

    services.openssh = {
      enable = lib.mkDefault true;

      ports = [ cfg.port ];

      banner = builtins.readFile ./banner.txt;

      settings.PasswordAuthentication = lib.mkForce true;
      settings.AuthenticationMethods = "publickey,password";
    };

  };

}
