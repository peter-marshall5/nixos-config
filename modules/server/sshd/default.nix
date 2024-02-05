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

    # Enable the OpenSSH daemon.
    services.openssh.enable = lib.mkDefault true;
    services.openssh.banner = builtins.readFile ./banner.txt;

    # Require both public key and password to log in via ssh.
    services.openssh = {
      settings.PasswordAuthentication = lib.mkForce true;
      settings.AuthenticationMethods = "publickey,password";
    };

  };

}
