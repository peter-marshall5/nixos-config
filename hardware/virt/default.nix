{ config, lib, modulesPath, ... }:

{

  imports = [
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")
  ];

  systemd.services."serial-getty@ttyS0".enable = true;

  boot.initrd.availableKernelModules = [ "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio" ];
  boot.initrd.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];
  boot.kernelModules = [ "kvm_intel" "kvm_amd" ];

  boot.kernelParams = [ "console=ttyS0" ];

}
