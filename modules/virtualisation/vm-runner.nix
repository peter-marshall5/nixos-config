{ config, lib, ... }: let
  cfg = config.services.vm-runner;
in {

  options.services.vm-runner = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    guests = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = builtins.listToAttrs (map ({ config, ... }: lib.nameValuePair "vm-${config.system.name}" {
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;
      script = (config.system.build.vm + "/bin/${config.system.build.vm.meta.mainProgram}");
    }) cfg.guests);
  };

}
