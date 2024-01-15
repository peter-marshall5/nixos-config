{ config, lib, ... }:

{

  options.ab.ssh = {

    enable = lib.mkOption {
      default = if config.ab.desktop.enable then false else true;
      type = lib.types.bool;
    };

  };

  config = lib.mkIf config.ab.ssh.enable {

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

  };

}
