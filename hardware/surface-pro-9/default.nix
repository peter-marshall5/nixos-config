{ config, lib, pkgs, modulesPath, ... }:

{

  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [ ./sound ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];

  boot.initrd.kernelModules = [ "nvme" "xhci_pci" "hid_generic" "atkbd" "surface_aggregator" "surface_aggregator_registry" "surface_aggregator_hub" "surface_hid_core" "8250_dw" "surface_hid" "intel_lpss" "intel_lpss_pci" "pinctrl_tigerlake" "usbhid" ];

  boot.kernelModules = [ "kvm-intel" ];

  boot.swraid.enable = lib.mkForce false;

  boot.initrd.luks.cryptoModules = [ "aes" "aes_generic" "cbc" "sha1" "sha256" "sha512" "af_alg" ];
  boot.initrd.includeDefaultModules = false;

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  services.thermald.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # IPU6 camera drivers. This doesn't work yet and causes weird issues
  # hardware.ipu6.enable = true;
  # hardware.ipu6.platform = "ipu6ep";

  # linux-surface kernel
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./kernel {
    baseKernel = pkgs.linux_latest;
  });

  environment.systemPackages = with pkgs; [
    surface-control
  ];

  services.iptsd.enable = true;
  services.iptsd.config = {
    Touch = {
      DisableOnPalm = true;
      DisableOnStylus = true;
    };
    Stylus = {
      TipDistance = 0.04;
    };
  };

}
