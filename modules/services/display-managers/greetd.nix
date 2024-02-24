{ config, lib, ... }: let
  cfg = config.services.greetd;
  dmCfg = config.services.xserver.displayManager;
  command = dmCfg.wrapper;
in {

  config.services.greetd.settings = lib.mkDefault {
    initial_session = lib.mkIf dmCfg.autoLogin.enable {
      inherit command;
      inherit (dmCfg.autoLogin) user;
    };
    default_session = {
      command = "${config.services.greetd.package}/bin/agreety --cmd ${command}";
    };
  };

}
