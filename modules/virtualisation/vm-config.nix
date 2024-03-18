{ config, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  system.activationScripts.users = lib.mkForce ""; # Fixes agenix error

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
    qemu.diskInterface = "virtio";

    qemu.package = config.virtualisation.host.pkgs.qemu_test;
    qemu.guestAgent.enable = false;

    graphics = false;
  };

}
