{ config, lib, pkgs, nixpkgs, modulesPath, ... }:

{

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.initrd.availableKernelModules = [ "ahci" "sd_mod" "uas" "usb_storage" ];

  boot.kernelModules = [ "kvm_intel" "kvm_amd" ];

  hardware.enableRedistributableFirmware = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;

  systemd.watchdog = {
    runtimeTime = "20s";
    rebootTime = "30s";
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
  '';

}