{ config, lib, pkgs, ... }: {

  config.virtualisation.vmVariant = { config, ... }: {
    system.build.vm-systemd-unit = let
      cfg = config.virtualisation;
      hostPkgs = cfg.host.pkgs;
      preStartScript = pkgs.writeShellApplication {
        name = "pre-start";
        runtimeInputs = [ ];
        text = ''
          [ -e ${toString cfg.stateDir} ] || mkdir -p ${toString cfg.stateDir}
          [ -e ${toString cfg.stateDir}/${config.system.name} ] || ${hostPkgs.btrfs-progs}/bin/btrfs subvolume create ${toString cfg.stateDir}/${config.system.name}
        '';
      };
    in lib.nameValuePair "microvm-${config.system.name}" {
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;
      script = "exec ${config.system.build.vm}/bin/${config.system.build.vm.meta.mainProgram}";
      serviceConfig = {
        ExecStartPre = [ "${preStartScript}/bin/pre-start" ];
      };
    };
  };

  config.system.build = {
    vm-systemd-unit = lib.mkDefault config.virtualisation.vmVariant.system.build.vm-systemd-unit;
  };

}
