{config, lib, ... }: {

  options.virtualisation.vms = lib.mkOption {
    default = [];
    type = lib.types.listOf lib.types.attrs;
  };

  config.systemd.services = builtins.listToAttrs (map (c: c.config.system.build.vm-systemd-unit) config.virtualisation.vms);

}
