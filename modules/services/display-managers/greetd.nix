{ config, lib, ... }: let
  cfg = config.services.greetd;
  dmCfg = config.services.xserver.displayManager;
in {

  options.services.greetd.command = lib.mkOption {
    type = lib.types.str;
    default = "/bin/sh";
  };

  config.services.greetd.settings = {
    initial_session = lib.mkIf dmCfg.autoLogin.enable {
      inherit (cfg) command;
      inherit (dmCfg.autoLogin) user;
    };
    default_session = {
      command = "${config.services.greetd.package}/bin/agreety --cmd ${cfg.command}";
    };
  };

}
