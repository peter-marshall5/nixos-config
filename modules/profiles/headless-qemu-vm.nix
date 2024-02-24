{ config, lib, modulesPath, ... }: let
  interface = "eth0";
  interfaceCfg = config.networking.interfaces;
  macAddress = if (builtins.hasAttr interface interfaceCfg) then interfaceCfg.${interface}.macAddress else null;
in {

  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    (modulesPath + "/profiles/headless.nix")
  ];

  virtualisation = {
    memorySize = lib.mkDefault 256;
    cores = lib.mkDefault 1;

    diskSize = lib.mkDefault 2048;
    useDefaultFilesystems = false;
    fileSystems = {
      "/" = {
        device = "/dev/vda";
        fsType = "btrfs";
        autoResize = true;
        autoFormat = true;
      };
    };
    diskImage = "/var/lib/guests/${config.system.name}.img";
    qemu.diskInterface = "virtio";

    # Use bridge network if we have a mac address specified
    qemu.networkingOptions = [(lib.concatStrings [
      "-nic "
      (if (macAddress != null) then "tap,mac=${macAddress}" else "user,id=user.0")
      ",ifname=vm-${config.system.name},model=virtio,script=no,downscript=no,name=eth0"
    ])];

    graphics = false;

    qemu.package = config.virtualisation.host.pkgs.qemu_test;
    qemu.guestAgent.enable = false;
  };

}
