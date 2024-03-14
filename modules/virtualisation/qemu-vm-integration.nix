{ config, lib, ... }: {

  options.virtualisation = {
    stateDir = lib.mkOption {
      default = /var/lib/microvm;
      type = lib.types.path;
    };
  };

  options.networking = {
    macAddress = lib.mkOption {
      type = lib.types.str;
    };
    ip = lib.mkOption {
      type = lib.types.str;
    };
  };

  config.virtualisation = {
    diskImage = "${toString config.virtualisation.stateDir}/${config.system.name}/state.img";

    qemu.networkingOptions = lib.mkForce [
      "-nic tap,mac=${config.networking.macAddress},ifname=vm-${config.system.name},model=virtio,script=no,downscript=no"
    ];
  };

}
