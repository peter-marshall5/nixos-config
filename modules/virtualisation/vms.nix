{config, lib, ... }: {

  options.virtualisation.vms = lib.mkOption {
    default = [];
    type = lib.types.listOf lib.types.attrs;
  };

  config.systemd.services = builtins.listToAttrs (map (c: c.config.system.build.vm-systemd-unit) config.virtualisation.vms);

  # Define hosts based on ip
  config.networking.hosts = builtins.listToAttrs (map (c: lib.nameValuePair "${c.config.virtualisation.vmVariant.networking.ip}%br1" [ "${c.config.networking.hostName}.vm" ]) config.virtualisation.vms);

}
