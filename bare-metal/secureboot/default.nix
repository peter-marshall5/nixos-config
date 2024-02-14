{ config, lib, ... }:

{

  options.ab.secureboot = {

    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };

  };

  config = lib.mkIf config.ab.secureboot.enable {

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
      settings = {
        timeout = 0;
        reboot-for-bitlocker = true;
      };
    };

  };
}
