{ config, lib, pkgs, modulesPath, ... }:

{

  imports = [
    (modulesPath + "/profiles/minimal.nix")
  ];

  boot.initrd.availableKernelModules = [ "ahci" "sd_mod" "uas" "usb_storage" ];

  boot.kernelModules = [ "kvm_intel" "kvm_amd" ];

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;

}
