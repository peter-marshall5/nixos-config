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
      "-nic user,restrict=y,guestfwd=tcp:10.0.2.100:19532-tcp:127.0.0.1:19532"
    ];
  };

}
