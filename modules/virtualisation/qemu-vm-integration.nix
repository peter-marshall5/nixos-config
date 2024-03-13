{ config, lib, ... }: {

  options.virtualisation = {
    macAddress = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    stateDir = lib.mkOption {
      default = /var/lib/microvm;
      type = lib.types.path;
    };
  };

  config.virtualisation = {
    diskImage = "${toString config.virtualisation.stateDir}/${config.system.name}/state.img";

    qemu.networkingOptions = lib.mkForce [
      "-nic tap,mac=${config.virtualisation.macAddress},ifname=vm-${config.system.name},model=virtio,script=no,downscript=no"
    ];
  };

}
