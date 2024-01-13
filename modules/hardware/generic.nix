{ config, lib, pkgs, ... }:

{

  boot.kernelModules = [ "kvm_intel" "kvm_amd" ];

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;

}
